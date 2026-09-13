//
//  PlaceSearchViewModel.swift
//  Presentation
//
//  "내 맘대로 고르기"의 검색 상태.
//  검색어가 있으면 GET /api/search로 서버가 이름 일치도 순으로 정렬한 결과를 받고,
//  검색어가 없으면 추천 목록(큐레이션 태그 전체)을 보여준다 — 서버는 빈 q를 400으로 막는다.
//  타이핑마다 요청하지 않도록 debounce를 두고, 결과는 offset으로 이어 받는다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class PlaceSearchViewModel {
    /// 타이핑이 멎기를 기다리는 시간. 짧으면 요청이 쏟아지고 길면 굼떠 보인다.
    private static let debounce = Duration.milliseconds(300)
    private static let pageSize = 20

    public var keyword = "" {
        didSet {
            guard keyword != oldValue else { return }
            scheduleSearch()
        }
    }

    /// 추천 목록을 훑을 때 쓰는 권역 칩. 검색 결과는 서버가 페이지로 끊어 주므로
    /// 여기에 걸면 "20건 중 3건"만 걸러져 전체가 그것뿐인 것처럼 보인다 —
    /// 그래서 검색어가 있는 동안에는 화면이 칩을 감춘다.
    var regionFilter: TripRegionFilter = .all

    /// 추천 목록을 처음 받는 동안에만 켠다. 검색은 목록을 통째로 가리지 않는다.
    public private(set) var isLoading = false
    public private(set) var isSearching = false
    public var errorMessage: String?

    /// 검색어가 없을 때 보여줄 전체 목록.
    private var catalog: [TaggedPlace] = []
    private var hasLoaded = false

    /// 지금 화면에 있는 검색 결과와, 그 결과가 속한 검색어.
    private var searchResults: [TaggedPlace] = []
    private var searchedQuery = ""
    private var total = 0

    /// 검색어에 걸린 축제. 페이징이 없어 매 페이지 응답으로 통째로 갱신한다.
    private var searchFestivals: [Festival] = []

    private var searchTask: Task<Void, Never>?

    /// 목록에 거리를 곁들이기 위한 현재 위치. 권한이 없으면 nil이고,
    /// 그러면 화면이 거리 자체를 안 그린다.
    private var userCoordinate: Coordinate?

    private let fetchSearchablePlacesUseCase: FetchSearchablePlacesUseCase
    private let searchDestinationsUseCase: SearchDestinationsUseCase
    private let fetchCurrentLocationUseCase: FetchCurrentLocationUseCase

    public init(
        fetchSearchablePlacesUseCase: FetchSearchablePlacesUseCase,
        searchDestinationsUseCase: SearchDestinationsUseCase,
        fetchCurrentLocationUseCase: FetchCurrentLocationUseCase
    ) {
        self.fetchSearchablePlacesUseCase = fetchSearchablePlacesUseCase
        self.searchDestinationsUseCase = searchDestinationsUseCase
        self.fetchCurrentLocationUseCase = fetchCurrentLocationUseCase
    }

    /// 현재 위치에서 이 장소까지의 직선 거리. 권한이 없거나 장소에 좌표가 없으면 nil이다.
    /// 태그 목록에서 온 추천 장소는 서버가 좌표를 안 줘서 항상 nil이다.
    func distanceKm(to place: TaggedPlace) -> Double? {
        guard let userCoordinate, let placeCoordinate = place.coordinate else { return nil }
        return userCoordinate.distanceKm(to: placeCoordinate)
    }

    // MARK: - 화면이 그리는 값

    public var trimmedKeyword: String {
        keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var hasKeyword: Bool { !trimmedKeyword.isEmpty }

    public var results: [TaggedPlace] {
        hasKeyword ? searchResults : recommended
    }

    /// 검색어에 걸린 축제. 검색어가 없으면 감춘다.
    public var festivals: [Festival] {
        hasKeyword ? searchFestivals : []
    }

    /// 검색어가 없을 때 보여줄 기본 목록. 프로토타입의 "사람 적은 추천 지역"이라
    /// 인구감소지역을 앞으로 끌어올린다 — 그게 이 앱이 미는 방향이다.
    private var recommended: [TaggedPlace] {
        let scoped = catalog.filter { regionFilter.contains($0) }
        return scoped.filter(\.isDepopulated) + scoped.filter { !$0.isDepopulated }
    }

    var listHeading: String {
        if hasKeyword { return L10n.placeSearchHeadingResults }
        guard regionFilter != .all else { return L10n.placeSearchHeadingRecommended }
        return L10n.placeSearchHeadingRegion(regionFilter.label)
    }

    /// 목록이 비어 있는 게 "결과 없음"인지 "아직 못 받음"인지 화면이 구분할 수 있게 한다.
    public var isEmptyResult: Bool {
        guard hasKeyword else { return hasLoaded && recommended.isEmpty }
        // 아직 이 검색어의 응답이 안 온 상태를 "결과 없음"으로 보여주면 깜빡인다.
        // 장소가 0건이어도 걸린 축제가 있으면 결과가 있는 것이다.
        return !isSearching && searchedQuery == trimmedKeyword && searchResults.isEmpty && searchFestivals.isEmpty
    }

    /// 서버가 알려준 전체 개수에 아직 못 미쳤으면 이어 받을 게 남아 있다.
    /// `isSearching`을 넣지 않는다 — 화면이 이 값으로 로딩 스피너의 존재 자체를 가리면
    /// 요청을 보내는 순간 스피너(와 그 `.task`)가 사라지면서 방금 보낸 요청이 취소된다.
    /// 취소는 네트워크 에러로 잡혀 알럿이 뜨고, count가 안 늘었으니 같은 페이지를 또 쏜다.
    public var hasMorePages: Bool {
        hasKeyword && searchResults.count < total
    }

    // MARK: - 불러오기

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // 권한이 이미 있을 때만 채워진다 — 여기서 다이얼로그를 띄우지는 않는다.
        async let coordinate = fetchCurrentLocationUseCase.execute()

        do throws(NetworkError) {
            catalog = try await fetchSearchablePlacesUseCase.execute()
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }

        userCoordinate = await coordinate
    }

    /// 목록 끝에 닿았을 때 다음 쪽을 붙인다. 이미 불러오는 중이면 건너뛴다 —
    /// 이 가드는 여기(호출 시점)에만 둔다. `hasMorePages`에 넣으면 화면의 스피너가
    /// 중간에 사라져 요청이 취소된다.
    public func loadMore() async {
        guard hasMorePages, !isSearching else { return }
        await runSearch(query: searchedQuery, offset: searchResults.count)
    }

    /// 실패 후 다시 시도. 검색 중이었으면 그 검색어를, 아니면 추천 목록을 다시 받는다.
    public func retry() async {
        if hasKeyword {
            await runSearch(query: trimmedKeyword, offset: 0)
        } else {
            hasLoaded = false
            await load()
        }
    }

    // MARK: - 검색

    /// 타이핑이 멎은 뒤에 한 번만 쏜다. 앞선 요청은 취소한다.
    private func scheduleSearch() {
        searchTask?.cancel()

        let query = trimmedKeyword
        guard !query.isEmpty else {
            // 검색어를 지우면 추천 목록으로 돌아간다 — 지난 결과를 남겨 두지 않는다.
            searchResults = []
            searchFestivals = []
            searchedQuery = ""
            total = 0
            isSearching = false
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: Self.debounce)
            guard !Task.isCancelled else { return }
            await self?.runSearch(query: query, offset: 0)
        }
    }

    private func runSearch(query: String, offset: Int) async {
        isSearching = true
        defer { isSearching = false }

        do throws(NetworkError) {
            let result = try await searchDestinationsUseCase.execute(
                query: query,
                limit: Self.pageSize,
                offset: offset
            )
            // 늦게 도착한 응답이 새 검색어의 결과를 덮지 않게 한다.
            guard !Task.isCancelled, query == trimmedKeyword else { return }

            searchResults = offset == 0 ? result.places.items : searchResults + result.places.items
            searchedQuery = query
            total = result.places.total
            // 페이징이 없는 필드라 첫 페이지 응답으로만 갱신한다 — 다음 페이지에도
            // 같은 값이 오지만 다시 덮어써도 결과는 같다.
            if offset == 0 { searchFestivals = result.festivals }
        } catch {
            // 빠른 스크롤로 트리거 뷰가 화면 밖으로 밀려나면 그 .task가 취소되고,
            // 진행 중이던 요청도 함께 취소된다("Connection interrupted"). 이 취소는
            // await 지점에서 곧장 에러로 던져져 위 guard의 Task.isCancelled 체크를
            // 건너뛰므로, 여기서 다시 한번 걸러 알럿을 띄우지 않는다.
            guard !Task.isCancelled else { return }
            errorMessage = L10n.loginNetworkError
        }
    }
}

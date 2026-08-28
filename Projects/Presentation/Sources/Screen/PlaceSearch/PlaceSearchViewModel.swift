//
//  PlaceSearchViewModel.swift
//  Presentation
//
//  "내 맘대로 고르기"의 검색 상태. 서버에 검색 API가 없어 목록을 한 번 받아두고
//  키워드는 로컬에서 거른다 — 타이핑마다 네트워크를 때리지 않기 위함.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class PlaceSearchViewModel {
    public var keyword = ""
    public private(set) var isLoading = false
    public var errorMessage: String?

    /// 한 번 받아 두는 검색 대상 전체. 키워드가 비면 이 목록이 그대로 보인다.
    private var catalog: [TaggedPlace] = []
    private var hasLoaded = false

    private let fetchSearchablePlacesUseCase: FetchSearchablePlacesUseCase

    public init(fetchSearchablePlacesUseCase: FetchSearchablePlacesUseCase) {
        self.fetchSearchablePlacesUseCase = fetchSearchablePlacesUseCase
    }

    public var hasKeyword: Bool {
        !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var results: [TaggedPlace] {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return recommended }
        return catalog.filter { $0.matches(query) }
    }

    /// 검색어가 없을 때 보여줄 기본 목록. 프로토타입의 "사람 적은 추천 지역"이라
    /// 인구감소지역을 앞으로 끌어올린다 — 그게 이 앱이 미는 방향이다.
    private var recommended: [TaggedPlace] {
        catalog.filter(\.isDepopulated) + catalog.filter { !$0.isDepopulated }
    }

    public var listHeading: String {
        hasKeyword ? L10n.placeSearchHeadingResults : L10n.placeSearchHeadingRecommended
    }

    /// 목록이 비어 있는 게 "결과 없음"인지 "아직 못 받음"인지 화면이 구분할 수 있게 한다.
    public var isEmptyResult: Bool { hasLoaded && results.isEmpty }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do throws(NetworkError) {
            catalog = try await fetchSearchablePlacesUseCase.execute()
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }
    }

    /// 실패 후 다시 시도. `hasLoaded` 가드를 풀고 처음부터 받는다.
    public func retry() async {
        hasLoaded = false
        await load()
    }
}

private extension TaggedPlace {
    /// 이름·주소·지역명 중 어디든 걸리면 결과에 넣는다 — "고성", "강원", "해수욕장" 모두 통하게.
    func matches(_ query: String) -> Bool {
        [name, address, sidoName, sigunguName].contains {
            $0.localizedCaseInsensitiveContains(query)
        }
    }
}

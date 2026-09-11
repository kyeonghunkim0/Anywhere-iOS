//
//  PlaceDetailViewModel.swift
//  Presentation
//
//  후기까지 한 응답에 실려 오므로 요청은 하나뿐이다.
//  "내 맘대로"에서 온 경우에 한해 confirmDestination()으로 "여기로 결정"까지 맡는다 —
//  랜덤 매칭과 같은 matchId 체계에 편입시킨 뒤(createCustomMatch) 그대로 confirm한다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class PlaceDetailViewModel {
    public private(set) var place: PlaceDetail?
    public private(set) var isLoading = false
    public private(set) var isConfirming = false
    public var errorMessage: String?

    private var hasLoaded = false

    private let placeId: String
    private let fetchPlaceDetailUseCase: FetchPlaceDetailUseCase
    private let createCustomMatchUseCase: CreateCustomMatchUseCase
    private let confirmMatchUseCase: ConfirmMatchUseCase

    public init(
        placeId: String,
        fetchPlaceDetailUseCase: FetchPlaceDetailUseCase,
        createCustomMatchUseCase: CreateCustomMatchUseCase,
        confirmMatchUseCase: ConfirmMatchUseCase
    ) {
        self.placeId = placeId
        self.fetchPlaceDetailUseCase = fetchPlaceDetailUseCase
        self.createCustomMatchUseCase = createCustomMatchUseCase
        self.confirmMatchUseCase = confirmMatchUseCase
    }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do throws(NetworkError) {
            place = try await fetchPlaceDetailUseCase.execute(placeId: placeId)
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }
    }

    public func retry() async {
        errorMessage = nil
        await load()
    }

    /// 도착 인증으로 넘길 때 쓰는 최소 식별자.
    public var placeRef: PlaceRef? {
        place.map { PlaceRef(id: $0.id, name: $0.name) }
    }

    /// "여기로 결정" — 성공하면 서버에 진행 중인 여정(CurrentTrip)이 생긴다.
    public func confirmDestination() async -> Bool {
        guard !isConfirming else { return false }
        isConfirming = true
        defer { isConfirming = false }

        do throws(MatchError) {
            let match = try await createCustomMatchUseCase.execute(placeId: placeId)
            _ = try await confirmMatchUseCase.execute(matchId: match.matchId)
            return true
        } catch {
            errorMessage = L10n.loginNetworkError
            return false
        }
    }
}

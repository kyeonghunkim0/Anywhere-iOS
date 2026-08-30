//
//  PlaceDetailViewModel.swift
//  Presentation
//
//  후기까지 한 응답에 실려 오므로 요청은 하나뿐이다.
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
    public var errorMessage: String?

    private var hasLoaded = false

    private let placeId: String
    private let fetchPlaceDetailUseCase: FetchPlaceDetailUseCase

    public init(placeId: String, fetchPlaceDetailUseCase: FetchPlaceDetailUseCase) {
        self.placeId = placeId
        self.fetchPlaceDetailUseCase = fetchPlaceDetailUseCase
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
}

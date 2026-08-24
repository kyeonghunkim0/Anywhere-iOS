//
//  MatchResultViewModel.swift
//  Presentation
//
//  확정 전 후보를 들고 있다가, 확정하거나 같은 조건으로 다시 뽑는다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class MatchResultViewModel {
    /// 화면이 그리는 현재 후보. 다시 뽑으면 통째로 교체된다.
    public private(set) var match: RandomMatch
    public private(set) var isWorking = false
    public var errorMessage: String?

    private let radiusKm: Double?
    private let fetchRandomMatchUseCase: FetchRandomMatchUseCase
    private let confirmMatchUseCase: ConfirmMatchUseCase

    public init(
        match: RandomMatch,
        radiusKm: Double?,
        fetchRandomMatchUseCase: FetchRandomMatchUseCase,
        confirmMatchUseCase: ConfirmMatchUseCase
    ) {
        self.match = match
        self.radiusKm = radiusKm
        self.fetchRandomMatchUseCase = fetchRandomMatchUseCase
        self.confirmMatchUseCase = confirmMatchUseCase
    }

    public var remainingMatches: Int { match.matchInfo.remainingMatches }
    public var canReroll: Bool { remainingMatches > 0 && !isWorking }

    /// 같은 조건으로 다시 뽑는다. 화면 이동 없이 후보만 바뀐다.
    public func reroll() async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }

        do throws(MatchError) {
            match = try await fetchRandomMatchUseCase.execute(radiusKm: radiusKm)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// 여기로 결정. 성공하면 true — 호출부가 홈으로 되돌린다.
    public func confirm() async -> Bool {
        guard !isWorking else { return false }
        isWorking = true
        defer { isWorking = false }

        do throws(MatchError) {
            _ = try await confirmMatchUseCase.execute(matchId: match.matchId)
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }

    private static func message(for error: MatchError) -> String {
        switch error {
        case .dailyLimitExceeded(let message), .notFound(let message), .rejected(let message):
            message
        case .network:
            L10n.loginNetworkError
        case .location(.authorizationDenied):
            L10n.locationPermissionDenied
        case .location(.unableToLocate):
            L10n.locationUnableToLocate
        }
    }
}

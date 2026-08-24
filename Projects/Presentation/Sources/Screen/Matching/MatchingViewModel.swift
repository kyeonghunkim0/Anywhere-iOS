//
//  MatchingViewModel.swift
//  Presentation
//
//  다트 애니메이션과 랜덤 매칭 API를 동시에 굴리고, 둘 다 끝났을 때만 결과를 내보낸다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class MatchingViewModel {
    /// 애니메이션이 끝나고 매칭도 성공했을 때만 채워진다. 화면은 이 값만 보고 이동한다.
    public private(set) var matchedResult: RandomMatch?
    /// 실패 메시지도 애니메이션이 끝난 뒤에 공개한다 — 다트가 날아가는 중에 알림이 뜨면 안 된다.
    public private(set) var errorMessage: String?

    private let radiusKm: Double?
    private let fetchRandomMatchUseCase: FetchRandomMatchUseCase

    /// 애니메이션 완료와 API 응답 중 먼저 끝난 쪽은 여기서 대기한다.
    private var animationFinished = false
    private var pendingMatch: RandomMatch?
    private var pendingError: String?
    private var hasResponded = false

    public init(radiusKm: Double?, fetchRandomMatchUseCase: FetchRandomMatchUseCase) {
        self.radiusKm = radiusKm
        self.fetchRandomMatchUseCase = fetchRandomMatchUseCase
    }

    public func load() async {
        // 재시도로 다시 불릴 수 있어 이전 결과를 지우고 시작한다.
        matchedResult = nil
        errorMessage = nil
        pendingMatch = nil
        pendingError = nil
        hasResponded = false

        do throws(MatchError) {
            pendingMatch = try await fetchRandomMatchUseCase.execute(radiusKm: radiusKm)
        } catch {
            pendingError = Self.message(for: error)
        }
        hasResponded = true
        publishIfReady()
    }

    public func animationDidFinish() {
        animationFinished = true
        publishIfReady()
    }

    /// 재시도할 때 애니메이션을 처음부터 다시 돌린다.
    public func prepareForRetry() {
        animationFinished = false
    }

    private func publishIfReady() {
        guard animationFinished, hasResponded else { return }
        matchedResult = pendingMatch
        errorMessage = pendingError
    }

    private static func message(for error: MatchError) -> String {
        switch error {
        case .dailyLimitExceeded(let message), .notFound(let message), .rejected(let message):
            message
        case .network:
            L10n.loginNetworkError
        }
    }
}

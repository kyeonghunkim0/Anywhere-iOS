//
//  ArrivalVerificationViewModel.swift
//  Presentation
//
//  화면에 들어온 즉시 GPS 체크인을 한 번 시도하고, 그 결과를 화면이 그릴 형태로 정리한다.
//  "500m 이탈"·"오늘 이미 체크인" 같은 판정은 전부 서버가 하므로 여기서 흉내내지 않는다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class ArrivalVerificationViewModel {
    /// 체크인 성공 결과. 채워지는 순간 화면이 "도장을 찍었어요"로 바뀐다.
    public private(set) var result: CheckInResult?
    public private(set) var isWorking = false
    public var errorMessage: String?

    private let place: PlaceRef
    private let checkInUseCase: CheckInUseCase

    public init(place: PlaceRef, checkInUseCase: CheckInUseCase) {
        self.place = place
        self.checkInUseCase = checkInUseCase
    }

    public var placeName: String { place.name }
    public var placeId: String { place.id }

    /// 이미 성공했으면 다시 부르지 않는다 — 체크인은 하루 한 번뿐이라 재요청이 그대로 실패가 된다.
    public func checkIn() async {
        guard result == nil, !isWorking else { return }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do throws(CheckInError) {
            result = try await checkInUseCase.execute(placeId: place.id)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// 도장 아래에 쌓이는 보상 줄. 서버가 실제로 내려준 값이 있을 때만 만든다 —
    /// 프로토타입의 "12 → 13곳" 같은 증감 표기는 이전 값을 모르므로 옮기지 않는다.
    public var rewards: [Reward] {
        guard let result else { return [] }
        let stamp = result.stamp

        var rewards: [Reward] = [
            Reward(
                id: "stamps",
                icon: .passport,
                label: L10n.arrivalRewardStamps(stamp.stampsEarned, stamp.totalStamps)
            )
        ]

        if stamp.bonusMultiplier > 1 {
            rewards.append(
                Reward(id: "bonus", icon: .flame, label: L10n.arrivalRewardBonus(stamp.bonusMultiplier))
            )
        }

        if stamp.regionLeveledUp {
            rewards.append(
                Reward(
                    id: "regionLevel",
                    icon: .sprout,
                    label: L10n.arrivalRewardRegionLevelUp(stamp.regionName, stamp.regionLevel)
                )
            )
        }

        rewards.append(
            contentsOf: result.newBadges.map { badge in
                Reward(id: badge.id, icon: .star, label: L10n.arrivalRewardBadge(badge.name))
            }
        )

        return rewards
    }

    public struct Reward: Identifiable, Sendable {
        public let id: String
        public let icon: DSIcon
        public let label: String
    }

    private static func message(for error: CheckInError) -> String {
        switch error {
        case .rejected(let message):
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

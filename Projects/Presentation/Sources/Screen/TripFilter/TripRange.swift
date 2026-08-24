//
//  TripRange.swift
//  Presentation
//
//  "아무데나 떠날 조건"에서 고르는 거리 구간.
//  값은 매칭 API의 radiusKm로 그대로 넘어간다 — nil이면 서버가 반경 제한 없이 고른다.
//

import UIComponents

enum TripRange: CaseIterable, Identifiable, Sendable {
    case nearby
    case dayTrip
    case anywhere

    /// 조건 화면을 처음 열었을 때 골라져 있는 값.
    static let `default`: TripRange = .dayTrip

    var id: Self { self }

    var radiusKm: Double? {
        switch self {
        case .nearby: return 120
        case .dayTrip: return 250
        case .anywhere: return nil
        }
    }

    var title: String {
        switch self {
        case .nearby: return L10n.tripFilterRangeNearbyTitle
        case .dayTrip: return L10n.tripFilterRangeDayTripTitle
        case .anywhere: return L10n.tripFilterRangeAnywhereTitle
        }
    }

    var subtitle: String {
        switch self {
        case .nearby: return L10n.tripFilterRangeNearbySubtitle
        case .dayTrip: return L10n.tripFilterRangeDayTripSubtitle
        case .anywhere: return L10n.tripFilterRangeAnywhereSubtitle
        }
    }
}

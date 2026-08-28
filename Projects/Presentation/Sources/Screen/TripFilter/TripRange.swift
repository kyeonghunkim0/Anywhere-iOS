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
    /// 랜덤을 쓰지 않고 직접 장소를 고르는 길. 거리 조건이 아니라 다른 화면으로 가는 입구다.
    case custom

    /// 조건 화면을 처음 열었을 때 골라져 있는 값.
    static let `default`: TripRange = .dayTrip

    var id: Self { self }

    var radiusKm: Double? {
        switch self {
        case .nearby: return 100
        case .dayTrip: return 200
        case .anywhere, .custom: return nil
        }
    }

    /// 이 행을 누르면 거리를 고르는 게 아니라 장소 검색으로 넘어간다.
    var opensPlaceSearch: Bool { self == .custom }

    var title: String {
        switch self {
        case .nearby: return L10n.tripFilterRangeNearbyTitle
        case .dayTrip: return L10n.tripFilterRangeDayTripTitle
        case .anywhere: return L10n.tripFilterRangeAnywhereTitle
        case .custom: return L10n.tripFilterRangeCustomTitle
        }
    }

    var subtitle: String {
        switch self {
        case .nearby: return L10n.tripFilterRangeNearbySubtitle
        case .dayTrip: return L10n.tripFilterRangeDayTripSubtitle
        case .anywhere: return L10n.tripFilterRangeAnywhereSubtitle
        case .custom: return L10n.tripFilterRangeCustomSubtitle
        }
    }
}

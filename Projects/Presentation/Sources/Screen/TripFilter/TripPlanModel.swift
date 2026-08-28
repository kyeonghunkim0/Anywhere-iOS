//
//  TripPlanModel.swift
//  Presentation
//
//  조건 화면과 장소 검색 화면이 함께 쓰는 선택 상태.
//  두 화면은 스택으로 떨어져 있어 서로 값을 건넬 방법이 없다 —
//  NavigationCoordinator와 같은 방식으로 환경에 실어 공유한다.
//

import Observation
import Domain

@MainActor
@Observable
public final class TripPlanModel {
    var range: TripRange = .default
    /// "내 맘대로"로 고른 목적지. 고르기 전에는 nil이고, 그동안 CTA가 잠긴다.
    var pickedPlace: TaggedPlace?

    public init() {}

    var isCustom: Bool { range == .custom }

    /// 홈에서 조건 화면에 새로 들어올 때마다 지난 선택을 지운다.
    func reset() {
        range = .default
        pickedPlace = nil
    }
}

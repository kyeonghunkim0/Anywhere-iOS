//
//  Route.swift
//  Presentation
//
//  앱이 이동할 수 있는 화면 목록. push/present 어느 쪽으로 띄우는지는
//  Route가 아니라 호출부(NavigationCoordinator 메서드)가 정한다 —
//  같은 화면을 상황에 따라 밀거나 올려야 하는 경우가 생기기 때문.
//

import Foundation

public enum Route: Hashable, Identifiable, Sendable {
    /// 내 프로필
    case profile
    /// 여권(도장 모음)
    case passport
    /// 지역 랭킹
    case ranking
    /// 설정
    case settings
    /// 랜덤 매칭 — 여행 시작
    case matching
    /// 도착 인증
    case arrivalVerification(matchId: String)
    /// 지역 상세
    case regionDetail(regionId: String)
    /// 장소 상세
    case placeDetail(placeId: String)
    /// 이용약관
    case terms
    /// 개인정보 처리방침
    case privacy

    public var id: Self { self }
}

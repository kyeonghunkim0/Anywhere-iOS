//
//  Route.swift
//  Presentation
//
//  앱이 이동할 수 있는 화면 목록. push/present 어느 쪽으로 띄우는지는
//  Route가 아니라 호출부(NavigationCoordinator 메서드)가 정한다 —
//  같은 화면을 상황에 따라 밀거나 올려야 하는 경우가 생기기 때문.
//

import Foundation
import Domain

public enum Route: Hashable, Identifiable, Sendable {
    /// 내 프로필
    case profile
    /// 지역 랭킹
    case ranking
    /// 설정
    case settings
    /// 아무데나 떠날 조건 — 매칭 전 거리 선택
    case tripFilter
    /// 랜덤 매칭 — 여행 시작. 조건 화면에서 고른 반경을 그대로 들고 간다.
    case matching(radiusKm: Double?)
    /// 매칭 결과 — 확정 전 후보 장소.
    /// 서버에 matchId로 매칭을 다시 읽는 API가 없어 결과를 그대로 싣는다.
    /// radiusKm은 "다른 곳 들러보기"가 같은 조건으로 재매칭하는 데 쓴다.
    case matchResult(match: RandomMatch, radiusKm: Double?)
    /// 내 맘대로 고르기 — 랜덤 대신 직접 목적지를 검색한다.
    case placeSearch
    /// 검색에서 고른 장소의 결과 창. 좌표가 없는 목록형 장소라 TaggedPlace를 그대로 싣는다.
    case pickedPlace(place: TaggedPlace)
    /// 도착 인증 — GPS 체크인으로 도장을 찍는다.
    /// 체크인 API가 matchId가 아니라 placeId를 받으므로 장소 식별자만 싣는다.
    case arrivalVerification(place: PlaceRef)
    /// 후기 남기기 — 체크인 직후 한 줄 후기.
    case review(place: PlaceRef)
    /// 여권 전체 목록 — 아직 못 간 지역과 못 얻은 뱃지까지 함께 본다.
    case passportDetail(userId: String, section: PassportSection)
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

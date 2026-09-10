//
//  TripRegionFilter.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isSpotSearch 화면 상단 권역 칩.
//  프로토타입은 목업 데이터에 있는 4개 권역만 뒀지만, 실제 데이터는 17개 시·도를
//  전부 담으므로 수도권·제주를 더해 어느 지역도 칩으로 못 닿는 일이 없게 한다.
//

import Domain
import UIComponents

enum TripRegionFilter: CaseIterable, Identifiable, Sendable {
    case all
    case chungcheong
    case gyeongsang
    case jeolla
    case gangwon
    case capital
    case jeju

    var id: Self { self }

    var label: String {
        switch self {
        case .all:         L10n.placeSearchRegionAll
        case .chungcheong: L10n.placeSearchRegionChungcheong
        case .gyeongsang:  L10n.placeSearchRegionGyeongsang
        case .jeolla:      L10n.placeSearchRegionJeolla
        case .gangwon:     L10n.placeSearchRegionGangwon
        case .capital:     L10n.placeSearchRegionCapital
        case .jeju:        L10n.placeSearchRegionJeju
        }
    }

    /// 이 권역에 속하는 시·도 이름. 서버가 주는 sidoName과 글자 그대로 맞춘다.
    private var sidoNames: Set<String> {
        switch self {
        case .all:
            []
        case .chungcheong:
            ["충청북도", "충청남도", "대전광역시", "세종특별자치시"]
        case .gyeongsang:
            ["경상북도", "경상남도", "대구광역시", "부산광역시", "울산광역시"]
        case .jeolla:
            ["전북특별자치도", "전라남도", "광주광역시"]
        case .gangwon:
            ["강원특별자치도"]
        case .capital:
            ["서울특별시", "인천광역시", "경기도"]
        case .jeju:
            ["제주특별자치도"]
        }
    }

    func contains(_ place: TaggedPlace) -> Bool {
        self == .all || sidoNames.contains(place.sidoName)
    }
}

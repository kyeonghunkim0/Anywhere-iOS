//
//  ViewModelFactory.swift
//  Presentation
//
//  화면이 필요로 하는 ViewModel을 만드는 방법 묶음. Presentation은 DIContainer를 모르므로
//  조립은 앱이 하고, 화면 쪽은 이 구조체 하나만 들고 다닌다 — 화면이 늘 때마다
//  RootView·RouteDestinationView의 파라미터 목록이 같이 길어지는 걸 막는다.
//

import Domain

@MainActor
public struct ViewModelFactory {
    let home: (User) -> HomeViewModel
    let matching: (Double?) -> MatchingViewModel
    let matchResult: (RandomMatch, Double?) -> MatchResultViewModel
    let placeSearch: () -> PlaceSearchViewModel
    let passport: (String) -> PassportViewModel
    let arrivalVerification: (PlaceRef) -> ArrivalVerificationViewModel
    let review: (PlaceRef) -> ReviewViewModel

    public init(
        home: @escaping (User) -> HomeViewModel,
        matching: @escaping (Double?) -> MatchingViewModel,
        matchResult: @escaping (RandomMatch, Double?) -> MatchResultViewModel,
        placeSearch: @escaping () -> PlaceSearchViewModel,
        passport: @escaping (String) -> PassportViewModel,
        arrivalVerification: @escaping (PlaceRef) -> ArrivalVerificationViewModel,
        review: @escaping (PlaceRef) -> ReviewViewModel
    ) {
        self.home = home
        self.matching = matching
        self.matchResult = matchResult
        self.placeSearch = placeSearch
        self.passport = passport
        self.arrivalVerification = arrivalVerification
        self.review = review
    }
}

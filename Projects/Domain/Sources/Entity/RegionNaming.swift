//
//  RegionNaming.swift
//  Domain
//
//  "중구"·"동구"처럼 여러 광역시에 같은 이름이 존재하는 기초자치단체를 화면에서 구분하기 위한
//  표시 이름 규칙. 시·도를 짧게 줄여 앞에 붙인다. (예: "인천 중구", "경기 부천시")
//

public enum RegionNaming {
    private static let shortSidoNames: [String: String] = [
        "서울특별시": "서울",
        "부산광역시": "부산",
        "대구광역시": "대구",
        "인천광역시": "인천",
        "광주광역시": "광주",
        "대전광역시": "대전",
        "울산광역시": "울산",
        "세종특별자치시": "세종",
        "경기도": "경기",
        "강원특별자치도": "강원",
        "충청북도": "충북",
        "충청남도": "충남",
        "전북특별자치도": "전북",
        "전라남도": "전남",
        "경상북도": "경북",
        "경상남도": "경남",
        "제주특별자치도": "제주",
    ]

    /// 시·도 이름의 짧은 표기. 매핑에 없으면 원본을 그대로 돌려준다.
    public static func shortSido(_ sidoName: String) -> String {
        shortSidoNames[sidoName] ?? sidoName
    }

    /// 화면 표시용 지역 이름. (예: "부산 중구", "경기 부천시", "세종시")
    public static func displayName(sido sidoName: String, sigungu sigunguName: String) -> String {
        let short = shortSido(sidoName)
        // 세종특별자치시 - 세종시처럼 시·도와 기초자치단체가 겹치면 한 번만 표기한다.
        guard !sigunguName.isEmpty else { return short }
        guard !sigunguName.hasPrefix(short) else { return sigunguName }
        return "\(short) \(sigunguName)"
    }
}

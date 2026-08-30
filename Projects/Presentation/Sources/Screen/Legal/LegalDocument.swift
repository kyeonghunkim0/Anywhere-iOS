//
//  LegalDocument.swift
//  Presentation
//
//  약관·처리방침 본문. 서버에 문서 API가 없어 앱이 들고 있는다.
//
//  ⚠️ 아래 문구는 Prototype.dc.html의 DOCS를 그대로 옮긴 것이다 — 법무 검토를 거친
//  실제 약관이 아니다. 실제 문안이 확정되면 이 파일의 내용만 교체하면 된다.
//  (4개 언어로 번역할 문서가 아니라 판단해 L10n으로 쪼개지 않았다.)
//

import Foundation

enum LegalDocument: String, Hashable, Sendable {
    case terms
    case privacy

    struct Section: Identifiable {
        var id: String { heading }
        let heading: String
        let body: String
    }

    var title: String {
        switch self {
        case .terms: "서비스 이용약관"
        case .privacy: "개인정보 처리방침"
        }
    }

    var meta: String { "시행일 2026.03.01 · 버전 1.2" }

    var intro: String {
        switch self {
        case .terms:
            "아무데나는 랜덤 매칭으로 한적한 지역 명소를 추천하고, GPS 도착 인증으로 도장을 모으는 여행 서비스입니다."
        case .privacy:
            "아무데나는 여행 매칭과 도착 인증에 필요한 최소한의 정보만 수집합니다."
        }
    }

    var sections: [Section] {
        switch self {
        case .terms:
            [
                Section(
                    heading: "제1조 (목적)",
                    body: "이 약관은 아무데나가 제공하는 랜덤 여행 매칭, 도장 수집, 지역 성장 게이지 서비스의 이용 조건과 절차를 정합니다."
                ),
                Section(
                    heading: "제2조 (도장 인증)",
                    body: "도장은 목적지 반경 내에서 GPS 위치가 확인될 때만 발급됩니다. 위치 정보를 조작한 인증은 무효 처리되며 여권 기록에서 삭제될 수 있습니다."
                ),
                Section(
                    heading: "제3조 (매칭 결과)",
                    body: "매칭 결과는 무작위로 산출되며 특정 지역의 방문을 보장하거나 강제하지 않습니다. 하루 재매칭 횟수는 서비스 정책에 따라 제한될 수 있습니다."
                ),
                Section(
                    heading: "제4조 (계정)",
                    body: "소셜 로그인으로 생성한 계정의 닉네임과 프로필 사진은 언제든 변경할 수 있으며, 탈퇴 시 수집한 도장과 뱃지 기록은 복구되지 않습니다."
                ),
            ]
        case .privacy:
            [
                Section(
                    heading: "수집 항목",
                    body: "소셜 로그인 식별자, 닉네임, 프로필 사진, 도착 인증 시점의 위치 좌표, 도장·뱃지 기록."
                ),
                Section(
                    heading: "위치 정보",
                    body: "위치는 도착 인증이 실행되는 순간에만 사용하며, 이동 경로를 지속적으로 추적하거나 저장하지 않습니다."
                ),
                Section(
                    heading: "보관 및 파기",
                    body: "계정 정보는 탈퇴 시 즉시 파기합니다. 인증 좌표는 도장 발급 검증 후 90일이 지나면 자동 삭제됩니다."
                ),
                Section(
                    heading: "제3자 제공",
                    body: "통계는 지역명 단위로 익명 집계되어 지자체 생활인구 리포트에 활용될 수 있으며, 개인을 식별할 수 있는 정보는 제공하지 않습니다."
                ),
            ]
        }
    }
}

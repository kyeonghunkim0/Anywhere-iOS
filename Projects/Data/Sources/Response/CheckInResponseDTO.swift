/// 체크인만 envelope을 쓰지 않는다 — stamp/newBadges가 최상위에 온다.
/// 실패(반경 이탈, 중복 체크인 등)는 HTTP 400 + stamp 없음으로 오므로 둘 다 옵셔널이다.
struct CheckInResponseDTO: Decodable, Sendable {
    let success: Bool
    let message: String
    let stamp: StampResultDTO?
    let newBadges: [EarnedBadgeDTO]?
}

/// {success, message?, data} 형태의 공용 envelope. check-in만 이 모양이 아니라
/// 별도 CheckInResponseDTO를 쓴다.
struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let message: String?
    let data: T
}

/// ranking/users, ranking/me는 data 옆에 period가 형제로 온다.
struct RankingResponseDTO<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let period: String
    let data: T
}

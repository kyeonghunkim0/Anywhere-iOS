/// 서버 공통 envelope. check-in만 이 모양이 아니라 별도 DTO를 쓴다.
struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let message: String?
    let data: T
}

/// data 없이 {success, message}만 오는 응답 (예: 여정 취소).
struct MessageResponse: Decodable, Sendable {
    let success: Bool
    let message: String?
}

/// stamp가 data로 감싸지지 않고 최상위에 온다.
struct CheckInResponseDTO: Decodable, Sendable {
    let success: Bool
    let message: String
    let stamp: StampResultDTO
}

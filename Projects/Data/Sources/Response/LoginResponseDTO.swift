struct LoginDataDTO: Decodable, Sendable {
    let token: String
    let user: UserDTO
}

struct ClaimQuestDataDTO: Decodable, Sendable {
    let badge: ClaimedBadgeDTO
}

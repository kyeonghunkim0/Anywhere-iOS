struct LoginDataDTO: Decodable, Sendable {
    let token: String
    let user: UserDTO
}

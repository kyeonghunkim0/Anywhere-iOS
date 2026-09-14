public struct BlockUserUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(userId: String) async throws(UserError) {
        try await userRepository.blockUser(userId: userId)
    }
}

public struct UnblockUserUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(userId: String) async throws(UserError) {
        try await userRepository.unblockUser(userId: userId)
    }
}

public struct FetchBlockedUsersUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws(NetworkError) -> [BlockedUser] {
        try await userRepository.fetchBlockedUsers()
    }
}

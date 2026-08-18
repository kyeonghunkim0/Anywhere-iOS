public struct FetchMyBadgesUseCase: Sendable {
    private let badgeRepository: BadgeRepository

    public init(badgeRepository: BadgeRepository) {
        self.badgeRepository = badgeRepository
    }

    public func execute() async throws(NetworkError) -> [Badge] {
        try await badgeRepository.fetchMyBadges()
    }
}

public struct FetchSeasonalBadgesUseCase: Sendable {
    private let badgeRepository: BadgeRepository

    public init(badgeRepository: BadgeRepository) {
        self.badgeRepository = badgeRepository
    }

    public func execute() async throws(NetworkError) -> [Badge] {
        try await badgeRepository.fetchSeasonalBadges()
    }
}

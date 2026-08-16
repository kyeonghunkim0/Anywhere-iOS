public struct ClaimQuestUseCase: Sendable {
    private let locationRepository: LocationRepository
    private let questRepository: QuestRepository

    public init(locationRepository: LocationRepository, questRepository: QuestRepository) {
        self.locationRepository = locationRepository
        self.questRepository = questRepository
    }

    public func execute(questId: String) async throws(QuestError) -> ClaimedBadge {
        let coordinate: Coordinate
        do {
            coordinate = try await locationRepository.currentCoordinate()
        } catch {
            throw .network(.unknown)
        }
        return try await questRepository.claimQuest(questId: questId, at: coordinate)
    }
}

public struct FetchQuestsUseCase: Sendable {
    private let questRepository: QuestRepository

    public init(questRepository: QuestRepository) {
        self.questRepository = questRepository
    }

    public func execute() async throws(NetworkError) -> [Quest] {
        try await questRepository.fetchQuests()
    }
}

public struct FetchCurationTagsUseCase: Sendable {
    private let tagRepository: TagRepository

    public init(tagRepository: TagRepository) {
        self.tagRepository = tagRepository
    }

    public func execute() async throws(NetworkError) -> [CurationTag] {
        try await tagRepository.fetchTags()
    }
}

public struct FetchPlacesByTagUseCase: Sendable {
    private let tagRepository: TagRepository

    public init(tagRepository: TagRepository) {
        self.tagRepository = tagRepository
    }

    public func execute(tagId: String) async throws(NetworkError) -> [TaggedPlace] {
        try await tagRepository.fetchPlaces(tagId: tagId)
    }
}

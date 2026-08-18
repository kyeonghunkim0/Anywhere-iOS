public protocol TagRepository: Sendable {
    func fetchTags() async throws(NetworkError) -> [CurationTag]
    func fetchPlaces(tagId: String) async throws(NetworkError) -> [TaggedPlace]
}

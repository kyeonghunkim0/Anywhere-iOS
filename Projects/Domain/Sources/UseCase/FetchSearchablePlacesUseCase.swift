/// "내 맘대로 고르기"가 검색할 장소 목록.
///
/// 서버에 장소 검색 엔드포인트가 없어, 큐레이션 태그에 걸린 장소를 전부 모아 검색 대상으로 삼는다.
/// 태그 하나가 실패해도 나머지로 계속한다 — 목록은 일부라도 보여주는 편이 낫다.
/// 태그 목록 자체를 못 받으면 검색할 대상이 없으므로 그때만 던진다.
public struct FetchSearchablePlacesUseCase: Sendable {
    private let tagRepository: TagRepository

    public init(tagRepository: TagRepository) {
        self.tagRepository = tagRepository
    }

    public func execute() async throws(NetworkError) -> [TaggedPlace] {
        let tags = try await tagRepository.fetchTags()

        var seen: Set<String> = []
        var places: [TaggedPlace] = []

        for tag in tags {
            guard let tagged = try? await tagRepository.fetchPlaces(tagId: tag.id) else { continue }
            for place in tagged where seen.insert(place.id).inserted {
                places.append(place)
            }
        }

        return places
    }
}

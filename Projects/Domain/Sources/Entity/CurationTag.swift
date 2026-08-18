/// GET /api/tags — 홈 화면 큐레이션 해시태그 칩.
public struct CurationTag: Sendable, Identifiable, Equatable {
    public let id: String
    public let label: String
    public let emoji: String?
    public let placeCount: Int

    public init(id: String, label: String, emoji: String?, placeCount: Int) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.placeCount = placeCount
    }
}

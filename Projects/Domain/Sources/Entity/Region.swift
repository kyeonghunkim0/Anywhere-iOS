public struct Region: Sendable, Identifiable, Equatable {
    public let id: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let level: Int
    public let visitorCount: Int

    public init(
        id: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        level: Int,
        visitorCount: Int
    ) {
        self.id = id
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.level = level
        self.visitorCount = visitorCount
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }
}

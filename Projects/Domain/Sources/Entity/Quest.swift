import Foundation

public enum QuestType: String, Sendable, Equatable {
    case seasonal = "SEASONAL"
    case hidden = "HIDDEN"
}

public struct Quest: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let type: QuestType
    public let imageURL: URL?
    public let startDate: Date?
    public let endDate: Date?
    /// 서버가 만들어 주는 표시용 문자열 (예: "D-7"). 계산 로직을 클라이언트에서 재구현하지 않기 위해 그대로 보관한다.
    public let dDay: String?
    public let radius: Double
    public let coordinate: Coordinate?
    public let regionName: String?
    public let isDepopulated: Bool
    public let isAcquired: Bool

    public init(
        id: String,
        title: String,
        description: String,
        type: QuestType,
        imageURL: URL?,
        startDate: Date?,
        endDate: Date?,
        dDay: String?,
        radius: Double,
        coordinate: Coordinate?,
        regionName: String?,
        isDepopulated: Bool,
        isAcquired: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.imageURL = imageURL
        self.startDate = startDate
        self.endDate = endDate
        self.dDay = dDay
        self.radius = radius
        self.coordinate = coordinate
        self.regionName = regionName
        self.isDepopulated = isDepopulated
        self.isAcquired = isAcquired
    }
}

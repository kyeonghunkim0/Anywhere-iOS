import Foundation

public struct ClaimedBadge: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let type: QuestType
    public let imageURL: URL?
    public let acquiredAt: Date
    public let visitorOrder: Int
    public let visitorOrderMessage: String

    public init(
        id: String,
        title: String,
        description: String,
        type: QuestType,
        imageURL: URL?,
        acquiredAt: Date,
        visitorOrder: Int,
        visitorOrderMessage: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.imageURL = imageURL
        self.acquiredAt = acquiredAt
        self.visitorOrder = visitorOrder
        self.visitorOrderMessage = visitorOrderMessage
    }
}

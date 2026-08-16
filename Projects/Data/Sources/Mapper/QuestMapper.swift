import Foundation
import Domain

extension QuestDTO {
    func toEntity() -> Quest {
        let coordinate: Coordinate? = {
            guard let mapX, let mapY else { return nil }
            return Coordinate(latitude: mapY, longitude: mapX)
        }()
        return Quest(
            id: id,
            title: title,
            description: description,
            type: QuestType(rawValue: type) ?? .seasonal,
            imageURL: imageUrl.flatMap(URL.init(string:)),
            startDate: startDate,
            endDate: endDate,
            dDay: dDay,
            radius: radius,
            coordinate: coordinate,
            regionName: regionName,
            isDepopulated: isDepopulated,
            isAcquired: isAcquired
        )
    }
}

extension ClaimedBadgeDTO {
    func toEntity() -> ClaimedBadge {
        ClaimedBadge(
            id: id,
            title: title,
            description: description,
            type: QuestType(rawValue: type) ?? .seasonal,
            imageURL: imageUrl.flatMap(URL.init(string:)),
            acquiredAt: acquiredAt,
            visitorOrder: visitorOrder,
            visitorOrderMessage: visitorOrderMessage
        )
    }
}

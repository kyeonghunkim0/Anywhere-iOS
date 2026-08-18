import Domain

extension BadgeDTO {
    func toEntity() -> Badge {
        let coordinate: Coordinate? = {
            guard let lat, let lng else { return nil }
            return Coordinate(latitude: lat, longitude: lng)
        }()
        return Badge(
            id: id,
            key: key,
            name: name,
            description: description,
            icon: icon,
            type: BadgeType(rawValue: type) ?? .seasonal,
            status: BadgeStatus(rawValue: status) ?? .available,
            earnedAt: earnedAt,
            daysRemaining: daysRemaining,
            isLocationHidden: isLocationHidden,
            coordinate: coordinate,
            radiusM: radiusM,
            regionId: regionId,
            placeId: placeId
        )
    }
}

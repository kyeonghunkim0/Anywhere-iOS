import Foundation
import Domain

extension PassportDTO {
    func toEntity() -> Passport {
        Passport(
            user: PassportUser(
                id: user.id,
                nickname: user.nickname,
                profileImageURL: user.profileImage.flatMap(URL.init(string:)),
                level: user.level,
                exp: user.exp,
                totalStamps: user.totalStamps,
                totalDistanceKm: user.totalDistanceKm
            ),
            contribution: PassportContribution(
                totalVisitedRegions: contribution.totalVisitedRegions,
                depopulatedVisitedCount: contribution.depopulatedVisitedCount,
                depopulatedRatioPercent: contribution.depopulatedRatioPercent,
                topPercentileText: contribution.topPercentileText
            ),
            completionRate: completionRate,
            badgeCollection: badgeCollection.map { dto in
                BadgeCollectionItem(
                    id: dto.id,
                    title: dto.title,
                    description: dto.description,
                    type: QuestType(rawValue: dto.type) ?? .seasonal,
                    imageURL: dto.imageUrl.flatMap(URL.init(string:)),
                    isAcquired: dto.isAcquired,
                    acquiredAt: dto.acquiredAt,
                    visitorOrder: dto.visitorOrder,
                    visitorOrderMessage: dto.visitorOrderMessage
                )
            },
            stampEngravings: stampEngravings.map { dto in
                StampEngraving(
                    id: dto.id,
                    placeName: dto.placeName,
                    regionName: dto.regionName,
                    isDepopulated: dto.isDepopulated,
                    visitorOrder: dto.visitorOrder,
                    engravingText: dto.engravingText,
                    checkedInAt: dto.checkedInAt
                )
            },
            regions: regions.map { dto in
                PassportRegion(
                    regionId: dto.regionId,
                    sidoName: dto.sidoName,
                    sigunguName: dto.sigunguName,
                    isDepopulated: dto.isDepopulated,
                    isVisited: dto.isVisited,
                    visitCount: dto.visitCount,
                    lastVisitedAt: dto.lastVisitedAt,
                    visitorOrder: dto.visitorOrder
                )
            }
        )
    }
}

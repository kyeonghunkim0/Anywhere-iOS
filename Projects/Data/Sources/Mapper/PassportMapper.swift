import Domain

extension PassportDTO {
    func toEntity() -> Passport {
        Passport(
            userId: userId,
            nickname: nickname,
            totalStamps: totalStamps,
            totalRegions: totalRegions,
            visitedRegions: visitedRegions,
            completionRate: completionRate,
            regions: regions.map { dto in
                PassportRegion(
                    regionId: dto.regionId,
                    sidoName: dto.sidoName,
                    sigunguName: dto.sigunguName,
                    isDepopulated: dto.isDepopulated,
                    isVisited: dto.isVisited,
                    visitCount: dto.visitCount,
                    lastVisitedAt: dto.lastVisitedAt,
                    level: dto.level,
                    visitorNumber: dto.visitorNumber,
                    badge: dto.badge?.toEntity()
                )
            }
        )
    }
}

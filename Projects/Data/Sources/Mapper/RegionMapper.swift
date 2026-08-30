import Foundation
import Domain

extension RegionDTO {
    func toEntity() -> Region {
        Region(id: id, sidoName: sidoName, sigunguName: sigunguName, isDepopulated: isDepopulated)
    }
}

extension GrowthRegionDTO {
    func toEntity() -> GrowthRegion {
        GrowthRegion(
            regionId: regionId,
            sidoName: sidoName,
            sigunguName: sigunguName,
            isDepopulated: isDepopulated,
            level: level,
            current: current,
            target: target,
            remaining: remaining
        )
    }
}

extension RegionDetailDTO {
    func toEntity() -> RegionDetail {
        RegionDetail(
            regionId: regionId,
            sidoName: sidoName,
            sigunguName: sigunguName,
            isDepopulated: isDepopulated,
            level: level,
            current: current,
            target: target,
            progressLabel: progressLabel,
            remainLabel: remainLabel,
            quote: quote,
            imageURL: imageUrl.flatMap(URL.init(string:)),
            imageCredit: imageCredit,
            stats: stats.map { $0.toEntity() },
            levels: levels.map {
                RegionLevelRow(level: $0.level, label: $0.label, reward: $0.reward, achieved: $0.achieved)
            }
        )
    }
}

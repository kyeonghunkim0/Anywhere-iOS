public struct FetchGrowthRegionsUseCase: Sendable {
    private let regionRepository: RegionRepository

    public init(regionRepository: RegionRepository) {
        self.regionRepository = regionRepository
    }

    public func execute(limit: Int? = nil) async throws(NetworkError) -> [GrowthRegion] {
        try await regionRepository.fetchGrowthRegions(limit: limit)
    }
}

public struct FetchRegionDetailUseCase: Sendable {
    private let regionRepository: RegionRepository

    public init(regionRepository: RegionRepository) {
        self.regionRepository = regionRepository
    }

    public func execute(regionId: String) async throws(NetworkError) -> RegionDetail {
        try await regionRepository.fetchRegionDetail(regionId: regionId)
    }
}

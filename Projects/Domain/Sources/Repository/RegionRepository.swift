public protocol RegionRepository: Sendable {
    /// 레벨업이 임박한 인구감소지역. limit 생략 시 서버 기본값 10.
    func fetchGrowthRegions(limit: Int?) async throws(NetworkError) -> [GrowthRegion]
    func fetchRegionDetail(regionId: String) async throws(NetworkError) -> RegionDetail
}

import Domain

final class RegionRepositoryImpl: RegionRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchGrowthRegions(limit: Int?) async throws(NetworkError) -> [GrowthRegion] {
        do {
            let envelope = try await httpClient.request(
                RegionAPI.growth(limit: limit),
                as: APIResponse<[GrowthRegionDTO]>.self
            )
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchRegionDetail(regionId: String) async throws(NetworkError) -> RegionDetail {
        do {
            let envelope = try await httpClient.request(
                RegionAPI.detail(regionId: regionId),
                as: APIResponse<RegionDetailDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}

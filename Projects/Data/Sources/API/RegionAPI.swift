enum RegionAPI: BaseAPI {
    case growth(limit: Int?)
    case detail(regionId: String)

    var path: String {
        switch self {
        case .growth: "/api/regions/growth"
        case .detail: "/api/regions/{regionId}"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .growth:                 [:]
        case .detail(let regionId):   ["regionId": regionId]
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: [String: String] {
        switch self {
        case .growth(let limit):
            guard let limit else { return [:] }
            return ["limit": String(limit)]
        case .detail:
            return [:]
        }
    }
}

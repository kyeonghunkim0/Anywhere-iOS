enum TagAPI: BaseAPI {
    case list
    case places(tagId: String)

    var path: String {
        switch self {
        case .list:   "/api/tags"
        case .places: "/api/tags/{tagId}/places"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .list:                [:]
        case .places(let tagId):   ["tagId": tagId]
        }
    }

    var method: HTTPMethod { .get }
}

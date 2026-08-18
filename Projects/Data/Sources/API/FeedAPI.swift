enum FeedAPI: BaseAPI {
    case recent(limit: Int?)

    var path: String { "/api/feed/recent" }
    var method: HTTPMethod { .get }

    var queryParameters: [String: String] {
        switch self {
        case .recent(let limit):
            guard let limit else { return [:] }
            return ["limit": String(limit)]
        }
    }
}

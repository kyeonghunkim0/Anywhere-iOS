enum SearchAPI: BaseAPI {
    /// 인증이 필요 없는 공개 검색. q가 비면 서버가 400으로 막는다.
    case search(query: String, limit: Int?, offset: Int?)

    var path: String { "/api/search" }

    var method: HTTPMethod { .get }

    var queryParameters: [String: String] {
        switch self {
        case .search(let query, let limit, let offset):
            var parameters = ["q": query]
            if let limit { parameters["limit"] = String(limit) }
            if let offset { parameters["offset"] = String(offset) }
            return parameters
        }
    }
}

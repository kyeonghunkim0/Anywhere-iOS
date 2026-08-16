enum RankingAPI: BaseAPI {
    case users(period: String)
    case me(period: String)

    var path: String {
        switch self {
        case .users: "/api/ranking/users"
        case .me:    "/api/ranking/me"
        }
    }

    var method: HTTPMethod { .get }

    var authorization: AuthorizationPolicy {
        switch self {
        case .users: .none
        case .me:    .required
        }
    }

    var queryParameters: [String: String] {
        switch self {
        case .users(let period), .me(let period):
            ["period": period]
        }
    }
}

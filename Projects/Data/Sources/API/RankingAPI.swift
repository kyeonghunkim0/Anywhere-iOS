enum RankingAPI: BaseAPI {
    case users
    case places
    case me

    var path: String {
        switch self {
        case .users:  "/api/ranking/users"
        case .places: "/api/ranking/places"
        case .me:     "/api/ranking/me"
        }
    }

    var method: HTTPMethod { .get }

    var authorization: AuthorizationPolicy {
        switch self {
        case .users, .places: .none
        case .me:             .required
        }
    }
}

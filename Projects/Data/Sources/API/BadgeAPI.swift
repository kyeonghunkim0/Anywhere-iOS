enum BadgeAPI: BaseAPI {
    case mine
    case seasonal

    var path: String {
        switch self {
        case .mine:     "/api/badges/me"
        case .seasonal: "/api/badges/seasonal"
        }
    }

    var method: HTTPMethod { .get }

    var authorization: AuthorizationPolicy {
        switch self {
        case .mine:     .required
        case .seasonal: .none
        }
    }
}

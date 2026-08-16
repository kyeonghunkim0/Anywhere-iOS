enum PassportAPI: BaseAPI {
    case mine
    case detail(userId: String)

    var path: String {
        switch self {
        case .mine:      "/api/passport"
        case .detail:    "/api/passport/{userId}"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .mine:                     [:]
        case .detail(let userId):       ["userId": userId]
        }
    }

    var method: HTTPMethod { .get }
    var authorization: AuthorizationPolicy { .required }
}

enum PassportAPI: BaseAPI {
    case detail(userId: String)

    var path: String { "/api/passport/{userId}" }

    var pathParameters: [String: String] {
        switch self {
        case .detail(let userId): ["userId": userId]
        }
    }

    var method: HTTPMethod { .get }
    var authorization: AuthorizationPolicy { .required }
}

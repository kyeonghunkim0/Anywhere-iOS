enum HomeAPI: BaseAPI {
    case fetch

    var path: String {
        switch self {
        case .fetch: "/api/home"
        }
    }

    var method: HTTPMethod { .get }

    var authorization: AuthorizationPolicy { .required }
}

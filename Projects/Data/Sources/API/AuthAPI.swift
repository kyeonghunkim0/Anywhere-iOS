enum AuthAPI: BaseAPI {
    case login(LoginRequestDTO)
    case me

    var path: String {
        switch self {
        case .login: "/api/auth/login"
        case .me:    "/api/auth/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login: .post
        case .me:    .get
        }
    }

    var authorization: AuthorizationPolicy {
        switch self {
        case .login: .none
        case .me:    .required
        }
    }

    var task: RequestTask {
        switch self {
        case .login(let request): .jsonBody(request)
        case .me:                 .plain
        }
    }
}

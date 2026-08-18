enum AuthAPI: BaseAPI {
    case login(LoginRequestDTO)

    var path: String { "/api/auth/login" }
    var method: HTTPMethod { .post }

    var task: RequestTask {
        switch self {
        case .login(let request): .jsonBody(request)
        }
    }
}

enum AuthAPI: BaseAPI {
    case login(LoginRequestDTO)
    case guestLogin(GuestLoginRequestDTO)
    case guestUpgrade(GuestUpgradeRequestDTO)

    var path: String {
        switch self {
        case .login:         "/api/auth/login"
        case .guestLogin:    "/api/auth/guest"
        case .guestUpgrade:  "/api/auth/guest/upgrade"
        }
    }

    var method: HTTPMethod { .post }

    /// 업그레이드는 게스트 토큰으로 인증된 상태에서만 호출한다 — 어떤 User row를 전환할지
    /// 서버가 토큰으로 판단하기 때문.
    var authorization: AuthorizationPolicy {
        switch self {
        case .login, .guestLogin: .none
        case .guestUpgrade:       .required
        }
    }

    var task: RequestTask {
        switch self {
        case .login(let request):        .jsonBody(request)
        case .guestLogin(let request):   .jsonBody(request)
        case .guestUpgrade(let request): .jsonBody(request)
        }
    }
}

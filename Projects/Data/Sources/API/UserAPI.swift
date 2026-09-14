enum UserAPI: BaseAPI {
    case me
    case stats
    case updateProfile(UpdateProfileRequestDTO)
    case updateSettings(UpdateSettingsRequestDTO)
    case detail(userId: String)
    case deleteMe
    case block(userId: String)
    case unblock(userId: String)
    case blocks

    var path: String {
        switch self {
        case .me, .updateProfile, .deleteMe: "/api/users/me"
        case .stats:                         "/api/users/me/stats"
        case .updateSettings:                "/api/users/me/settings"
        case .detail:                        "/api/users/{userId}/detail"
        case .block, .unblock:               "/api/users/{userId}/block"
        case .blocks:                        "/api/users/me/blocks"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .detail(let userId), .block(let userId), .unblock(let userId): ["userId": userId]
        default:                                                            [:]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .me, .stats, .detail, .blocks:   .get
        case .updateProfile, .updateSettings: .patch
        case .deleteMe, .unblock:             .delete
        case .block:                          .post
        }
    }

    var authorization: AuthorizationPolicy { .required }

    var task: RequestTask {
        switch self {
        case .updateProfile(let request):  .jsonBody(request)
        case .updateSettings(let request): .jsonBody(request)
        default:                           .plain
        }
    }
}

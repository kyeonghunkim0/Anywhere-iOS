enum UserAPI: BaseAPI {
    case me
    case stats
    case updateProfile(UpdateProfileRequestDTO)
    case updateSettings(UpdateSettingsRequestDTO)
    case detail(userId: String)

    var path: String {
        switch self {
        case .me, .updateProfile: "/api/users/me"
        case .stats:              "/api/users/me/stats"
        case .updateSettings:     "/api/users/me/settings"
        case .detail:             "/api/users/{userId}/detail"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .detail(let userId): ["userId": userId]
        default:                  [:]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .me, .stats, .detail:            .get
        case .updateProfile, .updateSettings: .patch
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

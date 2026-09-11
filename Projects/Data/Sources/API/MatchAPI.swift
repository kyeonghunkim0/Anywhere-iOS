enum MatchAPI: BaseAPI {
    case random(lat: Double, lng: Double, radiusKm: Double?, tagId: String?)
    /// "내 맘대로"로 고른 장소를 랜덤 매칭과 같은 matchId 체계로 편입한다.
    /// 응답 형태는 .random과 동일해서 이후 흐름(confirm 등)이 그대로 재사용된다.
    case custom(CustomMatchRequestDTO)
    case current
    case confirm(matchId: String)
    case cancel(matchId: String)

    var path: String {
        switch self {
        case .random:  "/api/match/random"
        case .custom:  "/api/match/custom"
        case .current: "/api/match/current"
        case .confirm: "/api/match/{matchId}/confirm"
        case .cancel:  "/api/match/{matchId}/cancel"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .confirm(let matchId), .cancel(let matchId): ["matchId": matchId]
        case .random, .custom, .current:                  [:]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .random, .current:           .get
        case .custom, .confirm, .cancel:  .post
        }
    }

    var authorization: AuthorizationPolicy { .required }

    var queryParameters: [String: String] {
        switch self {
        case .random(let lat, let lng, let radiusKm, let tagId):
            var params = ["lat": String(lat), "lng": String(lng)]
            if let radiusKm { params["radiusKm"] = String(radiusKm) }
            if let tagId { params["tagId"] = tagId }
            return params
        case .custom, .current, .confirm, .cancel:
            return [:]
        }
    }

    var task: RequestTask {
        switch self {
        case .custom(let request):                 .jsonBody(request)
        case .random, .current, .confirm, .cancel: .plain
        }
    }
}

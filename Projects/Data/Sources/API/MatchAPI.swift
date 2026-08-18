enum MatchAPI: BaseAPI {
    case random(lat: Double, lng: Double, radiusKm: Double?, tagId: String?)
    case current
    case confirm(matchId: String)
    case cancel(matchId: String)

    var path: String {
        switch self {
        case .random:  "/api/match/random"
        case .current: "/api/match/current"
        case .confirm: "/api/match/{matchId}/confirm"
        case .cancel:  "/api/match/{matchId}/cancel"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .confirm(let matchId), .cancel(let matchId): ["matchId": matchId]
        case .random, .current:                           [:]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .random, .current:  .get
        case .confirm, .cancel:  .post
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
        case .current, .confirm, .cancel:
            return [:]
        }
    }
}

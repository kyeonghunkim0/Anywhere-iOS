enum MatchAPI: BaseAPI {
    case random(lat: Double, lng: Double, durationFilter: String?, tag: String?)

    var path: String { "/api/match/random" }
    var method: HTTPMethod { .get }
    var authorization: AuthorizationPolicy { .required }

    var queryParameters: [String: String] {
        switch self {
        case .random(let lat, let lng, let durationFilter, let tag):
            var params = ["lat": String(lat), "lng": String(lng)]
            if let durationFilter { params["durationFilter"] = durationFilter }
            if let tag { params["tag"] = tag }
            return params
        }
    }
}

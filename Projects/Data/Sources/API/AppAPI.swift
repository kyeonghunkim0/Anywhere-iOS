enum AppAPI: BaseAPI {
    case info(version: String?, platform: String?)

    var path: String { "/api/app/info" }
    var method: HTTPMethod { .get }

    var queryParameters: [String: String] {
        switch self {
        case .info(let version, let platform):
            var parameters: [String: String] = [:]
            if let version { parameters["version"] = version }
            if let platform { parameters["platform"] = platform }
            return parameters
        }
    }
}

enum AppAPI: BaseAPI {
    case info(version: String?)

    var path: String { "/api/app/info" }
    var method: HTTPMethod { .get }

    var queryParameters: [String: String] {
        switch self {
        case .info(let version):
            guard let version else { return [:] }
            return ["version": version]
        }
    }
}

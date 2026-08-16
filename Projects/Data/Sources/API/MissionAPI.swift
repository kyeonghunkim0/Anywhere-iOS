enum MissionAPI: BaseAPI {
    case checkIn(CheckInRequestDTO)

    var path: String { "/api/mission/check-in" }
    var method: HTTPMethod { .post }
    var authorization: AuthorizationPolicy { .required }

    var task: RequestTask {
        switch self {
        case .checkIn(let request): .jsonBody(request)
        }
    }
}

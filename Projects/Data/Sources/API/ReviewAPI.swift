enum ReviewAPI: BaseAPI {
    case create(CreateReviewRequestDTO)
    case byPlace(placeId: String, limit: Int?)

    var path: String {
        switch self {
        case .create:  "/api/reviews"
        case .byPlace: "/api/reviews/places/{placeId}"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .create:                     [:]
        case .byPlace(let placeId, _):    ["placeId": placeId]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .create:  .post
        case .byPlace: .get
        }
    }

    var authorization: AuthorizationPolicy {
        switch self {
        case .create:  .required
        case .byPlace: .none
        }
    }

    var queryParameters: [String: String] {
        switch self {
        case .create:
            return [:]
        case .byPlace(_, let limit):
            guard let limit else { return [:] }
            return ["limit": String(limit)]
        }
    }

    var task: RequestTask {
        switch self {
        case .create(let request): .jsonBody(request)
        case .byPlace:             .plain
        }
    }
}

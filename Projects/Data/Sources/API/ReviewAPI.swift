enum ReviewAPI: BaseAPI {
    case create(CreateReviewRequestDTO)
    case byPlace(placeId: String, limit: Int?)
    case report(reviewId: String, ReportReviewRequestDTO)

    var path: String {
        switch self {
        case .create:  "/api/reviews"
        case .byPlace: "/api/reviews/places/{placeId}"
        case .report:  "/api/reviews/{reviewId}/report"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .create:                       [:]
        case .byPlace(let placeId, _):      ["placeId": placeId]
        case .report(let reviewId, _):      ["reviewId": reviewId]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .create:  .post
        case .byPlace: .get
        case .report:  .post
        }
    }

    var authorization: AuthorizationPolicy {
        switch self {
        case .create:  .required
        case .byPlace: .none
        case .report:  .required
        }
    }

    var queryParameters: [String: String] {
        switch self {
        case .create, .report:
            return [:]
        case .byPlace(_, let limit):
            guard let limit else { return [:] }
            return ["limit": String(limit)]
        }
    }

    var task: RequestTask {
        switch self {
        case .create(let request):       .jsonBody(request)
        case .byPlace:                   .plain
        case .report(_, let request):    .jsonBody(request)
        }
    }
}

enum PlaceAPI: BaseAPI {
    case detail(placeId: String)

    var path: String { "/api/places/{placeId}" }

    var pathParameters: [String: String] {
        switch self {
        case .detail(let placeId): ["placeId": placeId]
        }
    }

    var method: HTTPMethod { .get }
}

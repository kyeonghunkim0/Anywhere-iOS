enum FeedAPI: BaseAPI {
    case home

    var path: String { "/api/feed/home" }
    var method: HTTPMethod { .get }
}

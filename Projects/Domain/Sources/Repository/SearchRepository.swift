public protocol SearchRepository: Sendable {
    func search(query: String, limit: Int?, offset: Int?) async throws(NetworkError) -> SearchResult
}

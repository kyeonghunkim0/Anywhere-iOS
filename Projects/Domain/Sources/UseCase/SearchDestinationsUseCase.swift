import Foundation

/// "내 맘대로 고르기"의 서버 검색. 지역과 관광지를 한 번에 돌려준다.
///
/// 서버는 검색어가 비면 400으로 막으므로, 빈 검색어는 요청을 보내지 않고
/// 빈 결과로 처리한다 — 호출부가 매번 같은 가드를 두지 않게 한다.
public struct SearchDestinationsUseCase: Sendable {
    private let searchRepository: SearchRepository

    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    public func execute(
        query: String,
        limit: Int? = nil,
        offset: Int? = nil
    ) async throws(NetworkError) -> SearchResult {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty() }
        return try await searchRepository.search(query: trimmed, limit: limit, offset: offset)
    }
}

/// 서버 JWT의 저장/조회/삭제만 담당한다. 갱신·재발급 책임은 없다 (서버에 리프레시 토큰이 없다).
public protocol SessionRepository: Sendable {
    func saveToken(_ token: String) async
    func currentToken() async -> String?
    func clearToken() async
}

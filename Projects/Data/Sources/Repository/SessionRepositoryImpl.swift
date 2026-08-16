import Domain
final class SessionRepositoryImpl: SessionRepository, Sendable {
    private let tokenStore: TokenStore

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    func saveToken(_ token: String) async {
        await tokenStore.save(token)
    }

    func currentToken() async -> String? {
        await tokenStore.currentToken()
    }

    func clearToken() async {
        await tokenStore.clear()
    }
}

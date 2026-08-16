actor TokenStore {
    private let storage: KeychainStorage
    private let tokenKey = "jwt"
    private var cachedToken: String?

    init(storage: KeychainStorage = KeychainStorage()) {
        self.storage = storage
        self.cachedToken = storage.load(for: tokenKey)
    }

    func save(_ token: String) {
        cachedToken = token
        storage.save(token, for: tokenKey)
    }

    func currentToken() -> String? {
        cachedToken
    }

    func clear() {
        cachedToken = nil
        storage.delete(for: tokenKey)
    }
}

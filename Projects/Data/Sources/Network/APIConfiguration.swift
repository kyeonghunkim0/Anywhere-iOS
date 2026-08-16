import Foundation

/// baseURL은 여기서만 주입받는다. BaseAPI를 채택하는 각 enum은 이 값을 모른다.
public struct APIConfiguration: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

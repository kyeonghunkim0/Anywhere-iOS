/// Data 내부에서만 쓰인다. Repository 구현체가 이걸 Domain 에러로 번역해 밖으로 내보낸다.
enum TransportError: Error, Sendable {
    /// path의 `{key}`가 pathParameters로 채워지지 않은 채 남았다.
    case invalidPath
    /// 401. 토큰이 없거나 만료됨.
    case unauthorized
    /// 400. message는 서버가 준 한국어 사유.
    case badRequest(message: String)
    /// 404.
    case notFound
    /// 429. message는 서버가 준 사유.
    case rateLimited(message: String)
    case decoding(any Error)
    case offline
    case server
    case unknown(statusCode: Int)
}

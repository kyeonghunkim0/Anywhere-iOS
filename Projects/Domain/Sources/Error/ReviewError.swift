public enum ReviewError: Error, Sendable {
    /// HTTP 400. 빈 내용 / 500자 초과 등 서버가 준 사유.
    case rejected(message: String)
    /// HTTP 404. 존재하지 않는 관광지.
    case placeNotFound(message: String)
    case network(NetworkError)
}

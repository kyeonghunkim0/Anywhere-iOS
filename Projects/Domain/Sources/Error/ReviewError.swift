public enum ReviewError: Error, Sendable {
    /// HTTP 400. 빈 내용 / 500자 초과 등 서버가 준 사유.
    case rejected(message: String)
    /// HTTP 404. 존재하지 않는 관광지.
    case placeNotFound(message: String)
    /// HTTP 409. 이미 신고한 후기 — 호출부는 이걸 실패가 아니라 "신고 완료"로 취급해도 된다.
    case alreadyReported
    case network(NetworkError)
}

enum AuthorizationPolicy: Sendable {
    /// 토큰을 붙이지 않는다. (공개 엔드포인트)
    case none
    /// 토큰이 없으면 요청을 보내지 않고 즉시 실패시킨다.
    case required
}

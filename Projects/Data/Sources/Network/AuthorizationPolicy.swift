enum AuthorizationPolicy: Sendable {
    /// 토큰을 붙이지 않는다.
    case none
    /// 토큰이 없으면 요청을 보내지 않고 즉시 실패시킨다.
    case required
    /// 토큰이 있으면 붙이고, 없어도 그대로 보낸다. (예: GET /api/quests)
    case optional
}

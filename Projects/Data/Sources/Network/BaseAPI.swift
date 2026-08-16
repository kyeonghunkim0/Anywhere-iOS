/// Anywhere 서버 엔드포인트 하나를 표현하는 단위. Swagger의 path 템플릿과
/// `path`를 글자 그대로 같게 유지하고, path parameter는 문자열 보간이 아니라
/// `pathParameters` 딕셔너리로 선언해 URL 빌더가 치환하게 한다.
protocol BaseAPI: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var pathParameters: [String: String] { get }
    var queryParameters: [String: String] { get }
    var task: RequestTask { get }
    var authorization: AuthorizationPolicy { get }
}

extension BaseAPI {
    var pathParameters: [String: String] { [:] }
    var queryParameters: [String: String] { [:] }
    var task: RequestTask { .plain }
    var authorization: AuthorizationPolicy { .none }
}

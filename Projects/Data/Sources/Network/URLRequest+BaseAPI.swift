import Foundation

extension URLRequest {
    /// `api.path`의 `{key}`를 `api.pathParameters[key]`로 치환하고, 쿼리·바디·Bearer를 조립한다.
    /// 치환 후에도 `{`가 남아 있으면 파라미터 누락이므로 `.invalidPath`를 던진다.
    init(api: some BaseAPI, baseURL: URL, token: String?, encoder: JSONEncoder) throws(TransportError) {
        var resolvedPath = api.path
        for (key, value) in api.pathParameters {
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
            resolvedPath = resolvedPath.replacingOccurrences(of: "{\(key)}", with: encodedValue)
        }
        guard !resolvedPath.contains("{") else {
            throw TransportError.invalidPath
        }

        guard var components = URLComponents(url: baseURL.appendingPathComponent(resolvedPath), resolvingAgainstBaseURL: false) else {
            throw TransportError.invalidPath
        }
        if !api.queryParameters.isEmpty {
            components.queryItems = api.queryParameters
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else {
            throw TransportError.invalidPath
        }

        self.init(url: url)
        httpMethod = api.method.rawValue

        // 서버는 주 서브태그(en-US → en)만 보고, 미지원 언어는 한국어로 폴백한다.
        // 시스템 로케일 문자열을 변환 없이 그대로 넘긴다. 앱 내 언어 선택이 생기면 이 값만 바꾸면 된다.
        setValue(Locale.preferredLanguages.first ?? "ko", forHTTPHeaderField: "Accept-Language")

        switch api.authorization {
        case .none:
            break
        case .required:
            guard let token else { throw TransportError.unauthorized }
            setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        switch api.task {
        case .plain:
            break
        case .jsonBody(let body):
            do {
                httpBody = try encoder.encode(body)
                setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw TransportError.decoding(error)
            }
        }
    }
}

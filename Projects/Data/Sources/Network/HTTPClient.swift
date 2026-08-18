import Foundation

/// HTTP 상태코드와 디코딩된 값을 함께 돌려준다.
/// (예: POST /api/auth/login은 신규 가입 여부를 body가 아닌 201/200으로만 알려준다.)
struct HTTPResponseEnvelope<T: Sendable>: Sendable {
    let statusCode: Int
    let value: T
}

actor HTTPClient {
    private let session: URLSession
    private let configuration: APIConfiguration
    private let tokenProvider: @Sendable () async -> String?

    init(
        configuration: APIConfiguration,
        tokenProvider: @escaping @Sendable () async -> String?,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.tokenProvider = tokenProvider
        self.session = session
    }

    func request<T: Decodable & Sendable>(_ api: some BaseAPI, as type: T.Type) async throws(TransportError) -> HTTPResponseEnvelope<T> {
        let token = await tokenProvider()
        let urlRequest = try URLRequest(api: api, baseURL: configuration.baseURL, token: token, encoder: JSONCoder.encoder)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
            throw TransportError.offline
        } catch {
            throw TransportError.server
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransportError.unknown(statusCode: -1)
        }

        try Self.validate(statusCode: httpResponse.statusCode, data: data)

        do {
            let value = try JSONCoder.decoder.decode(T.self, from: data)
            return HTTPResponseEnvelope(statusCode: httpResponse.statusCode, value: value)
        } catch {
            throw TransportError.decoding(error)
        }
    }

    private static func validate(statusCode: Int, data: Data) throws(TransportError) {
        switch statusCode {
        case 200..<300:
            return
        case 401:
            throw .unauthorized
        case 404:
            throw .notFound(message: Self.serverMessage(from: data))
        case 429:
            throw .rateLimited(message: Self.serverMessage(from: data))
        case 400..<500:
            throw .badRequest(message: Self.serverMessage(from: data))
        case 500..<600:
            throw .server
        default:
            throw .unknown(statusCode: statusCode)
        }
    }

    private static func serverMessage(from data: Data) -> String {
        struct ErrorEnvelope: Decodable { let message: String? }
        return (try? JSONCoder.decoder.decode(ErrorEnvelope.self, from: data))?.message ?? "알 수 없는 오류가 발생했습니다."
    }
}

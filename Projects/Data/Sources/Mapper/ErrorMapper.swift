import Domain

/// TransportError는 이 파일 밖으로 나가지 않는다. 각 Repository 구현체가
/// 자기 오퍼레이션에 맞는 Domain 에러로 번역할 때만 이 함수들을 쓴다.
enum ErrorMapper {
    static func network(_ error: TransportError) -> NetworkError {
        switch error {
        case .offline:
            .offline
        case .server:
            .server
        case .invalidPath, .unauthorized, .badRequest, .notFound, .rateLimited, .decoding, .unknown:
            .unknown
        }
    }

    static func auth(_ error: TransportError) -> AuthError {
        switch error {
        case .unauthorized:
            .sessionExpired
        case .badRequest(let message):
            .rejected(message: message)
        default:
            .network(network(error))
        }
    }

    static func profile(_ error: TransportError) -> ProfileError {
        switch error {
        case .unauthorized:
            .sessionExpired
        case .badRequest(let message):
            .rejected(message: message)
        default:
            .network(network(error))
        }
    }

    /// 매칭은 오퍼레이션마다 404의 뜻이 다르다 — 후보 조회는 "주변에 없음",
    /// confirm/cancel은 "존재하지 않는 매칭". 메시지를 그대로 실어 화면이 그대로 보여줄 수 있게 한다.
    static func match(_ error: TransportError) -> MatchError {
        switch error {
        case .rateLimited(let message):
            .dailyLimitExceeded(message: message)
        case .notFound(let message):
            .notFound(message: message)
        case .badRequest(let message):
            .rejected(message: message)
        default:
            .network(network(error))
        }
    }

    static func checkIn(_ error: TransportError) -> CheckInError {
        switch error {
        case .badRequest(let message):
            .rejected(message: message)
        default:
            .network(network(error))
        }
    }

    static func review(_ error: TransportError) -> ReviewError {
        switch error {
        case .notFound(let message):
            .placeNotFound(message: message)
        case .badRequest(let message):
            .rejected(message: message)
        default:
            .network(network(error))
        }
    }
}

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

    static func match(_ error: TransportError) -> MatchError {
        switch error {
        case .rateLimited(let message):
            .dailyLimitExceeded(message: message)
        case .notFound:
            .noPlaceNearby
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

    static func quest(_ error: TransportError) -> QuestError {
        switch error {
        case .badRequest(let message):
            .rejected(message: message)
        default:
            .network(network(error))
        }
    }
}

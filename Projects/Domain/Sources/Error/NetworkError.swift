/// 전송 실패의 도메인 표현. Data의 TransportError는 이 밖으로 나가지 않는다.
public enum NetworkError: Error, Sendable, Equatable {
    case offline
    case server
    case unknown
}

import Domain
/// Data 모듈의 유일한 public 진입점.
/// HTTPClient/TokenStore 같은 인프라 타입은 internal로 숨기고, Domain 프로토콜
/// 타입으로만 Repository를 노출한다. DIContainer는 이 컨테이너 하나만 알면 된다.
public final class DataContainer: Sendable {
    private let tokenStore: TokenStore
    private let httpClient: HTTPClient
    // CLLocationManager는 델리게이트/continuation 상태를 갖는 단일 리소스라
    // 다른 Repository들과 달리 요청마다 새로 만들지 않고 하나만 공유한다.
    private let sharedLocationRepository: LocationRepositoryImpl

    public init(configuration: APIConfiguration) {
        let tokenStore = TokenStore()
        self.tokenStore = tokenStore
        self.httpClient = HTTPClient(
            configuration: configuration,
            tokenProvider: { await tokenStore.currentToken() }
        )
        self.sharedLocationRepository = LocationRepositoryImpl()
    }

    public var authRepository: AuthRepository { AuthRepositoryImpl(httpClient: httpClient) }
    public var matchRepository: MatchRepository { MatchRepositoryImpl(httpClient: httpClient) }
    public var missionRepository: MissionRepository { MissionRepositoryImpl(httpClient: httpClient) }
    public var passportRepository: PassportRepository { PassportRepositoryImpl(httpClient: httpClient) }
    public var rankingRepository: RankingRepository { RankingRepositoryImpl(httpClient: httpClient) }
    public var feedRepository: FeedRepository { FeedRepositoryImpl(httpClient: httpClient) }
    public var questRepository: QuestRepository { QuestRepositoryImpl(httpClient: httpClient) }
    public var locationRepository: LocationRepository { sharedLocationRepository }
    public var sessionRepository: SessionRepository { SessionRepositoryImpl(tokenStore: tokenStore) }
}

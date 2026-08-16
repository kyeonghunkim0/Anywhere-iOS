import Data
import Domain

/// 앱 전체의 합성 루트. Presentation은 이 컨테이너의 UseCase 프로퍼티만 알면 되고,
/// DataContainer/SocialAuthenticatingAdapter 같은 구현 세부는 여기서만 조립된다.
public final class AppDependencyContainer: Sendable {
    private let dataContainer: DataContainer
    private let socialAuthenticating: SocialAuthenticating

    public init(apiConfiguration: APIConfiguration) {
        self.dataContainer = DataContainer(configuration: apiConfiguration)
        self.socialAuthenticating = SocialAuthenticatingAdapter()
    }

    public var signInUseCase: SignInUseCase {
        SignInUseCase(
            socialAuthenticating: socialAuthenticating,
            authRepository: dataContainer.authRepository,
            sessionRepository: dataContainer.sessionRepository
        )
    }

    public var signOutUseCase: SignOutUseCase {
        SignOutUseCase(socialAuthenticating: socialAuthenticating, sessionRepository: dataContainer.sessionRepository)
    }

    public var restoreSessionUseCase: RestoreSessionUseCase {
        RestoreSessionUseCase(sessionRepository: dataContainer.sessionRepository, authRepository: dataContainer.authRepository)
    }

    public var fetchMyProfileUseCase: FetchMyProfileUseCase {
        FetchMyProfileUseCase(authRepository: dataContainer.authRepository)
    }

    public var fetchRandomMatchUseCase: FetchRandomMatchUseCase {
        FetchRandomMatchUseCase(locationRepository: dataContainer.locationRepository, matchRepository: dataContainer.matchRepository)
    }

    public var checkInUseCase: CheckInUseCase {
        CheckInUseCase(locationRepository: dataContainer.locationRepository, missionRepository: dataContainer.missionRepository)
    }

    public var fetchPassportUseCase: FetchPassportUseCase {
        FetchPassportUseCase(passportRepository: dataContainer.passportRepository)
    }

    public var fetchUserRankingUseCase: FetchUserRankingUseCase {
        FetchUserRankingUseCase(rankingRepository: dataContainer.rankingRepository)
    }

    public var fetchMyRankUseCase: FetchMyRankUseCase {
        FetchMyRankUseCase(rankingRepository: dataContainer.rankingRepository)
    }

    public var fetchHomeFeedUseCase: FetchHomeFeedUseCase {
        FetchHomeFeedUseCase(feedRepository: dataContainer.feedRepository)
    }

    public var fetchQuestsUseCase: FetchQuestsUseCase {
        FetchQuestsUseCase(questRepository: dataContainer.questRepository)
    }

    public var claimQuestUseCase: ClaimQuestUseCase {
        ClaimQuestUseCase(locationRepository: dataContainer.locationRepository, questRepository: dataContainer.questRepository)
    }
}

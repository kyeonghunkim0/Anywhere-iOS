import Auth
import Data
import Domain
import Foundation

/// 앱 전체의 합성 루트. Presentation·AnywhereApp은 이 컨테이너만 알면 되고,
/// DataContainer/SocialAuthenticatingAdapter/Auth SDK 초기화 같은 구현 세부는
/// 여기서만 조립된다 — AnywhereApp이 Data/Auth를 직접 import하지 않아도 되게 한다.
public final class AppDependencyContainer: Sendable {
    private let dataContainer: DataContainer
    private let socialAuthenticating: SocialAuthenticating

    public init(baseURL: URL) {
        self.dataContainer = DataContainer(configuration: APIConfiguration(baseURL: baseURL))
        self.socialAuthenticating = SocialAuthenticatingAdapter()
    }

    /// Firebase/GoogleSignIn SDK 초기화. 앱 시작 시 한 번 호출해야 한다.
    public static func configureSocialAuth() {
        AuthConfiguration.configure()
    }

    /// Google 로그인 리다이렉트 URL 처리. App의 onOpenURL에서 호출해야 한다.
    @discardableResult
    public static func handleSocialAuthURL(_ url: URL) -> Bool {
        AuthConfiguration.handle(url)
    }

    // MARK: - 인증 / 프로필

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
        RestoreSessionUseCase(
            sessionRepository: dataContainer.sessionRepository,
            userRepository: dataContainer.userRepository
        )
    }

    public var fetchMyProfileUseCase: FetchMyProfileUseCase {
        FetchMyProfileUseCase(userRepository: dataContainer.userRepository)
    }

    public var fetchProfileStatsUseCase: FetchProfileStatsUseCase {
        FetchProfileStatsUseCase(userRepository: dataContainer.userRepository)
    }

    public var updateProfileUseCase: UpdateProfileUseCase {
        UpdateProfileUseCase(userRepository: dataContainer.userRepository)
    }

    public var updateSettingsUseCase: UpdateSettingsUseCase {
        UpdateSettingsUseCase(userRepository: dataContainer.userRepository)
    }

    public var fetchRankerDetailUseCase: FetchRankerDetailUseCase {
        FetchRankerDetailUseCase(userRepository: dataContainer.userRepository)
    }

    // MARK: - 매칭 / 여정 / 체크인

    public var requestLocationPermissionUseCase: RequestLocationPermissionUseCase {
        RequestLocationPermissionUseCase(locationRepository: dataContainer.locationRepository)
    }

    public var fetchRandomMatchUseCase: FetchRandomMatchUseCase {
        FetchRandomMatchUseCase(
            locationRepository: dataContainer.locationRepository,
            matchRepository: dataContainer.matchRepository
        )
    }

    public var confirmMatchUseCase: ConfirmMatchUseCase {
        ConfirmMatchUseCase(matchRepository: dataContainer.matchRepository)
    }

    public var cancelMatchUseCase: CancelMatchUseCase {
        CancelMatchUseCase(matchRepository: dataContainer.matchRepository)
    }

    public var fetchCurrentTripUseCase: FetchCurrentTripUseCase {
        FetchCurrentTripUseCase(matchRepository: dataContainer.matchRepository)
    }

    public var checkInUseCase: CheckInUseCase {
        CheckInUseCase(
            locationRepository: dataContainer.locationRepository,
            missionRepository: dataContainer.missionRepository
        )
    }

    // MARK: - 여권 / 랭킹 / 피드

    public var fetchPassportUseCase: FetchPassportUseCase {
        FetchPassportUseCase(passportRepository: dataContainer.passportRepository)
    }

    public var fetchUserRankingUseCase: FetchUserRankingUseCase {
        FetchUserRankingUseCase(rankingRepository: dataContainer.rankingRepository)
    }

    public var fetchPlaceRankingUseCase: FetchPlaceRankingUseCase {
        FetchPlaceRankingUseCase(rankingRepository: dataContainer.rankingRepository)
    }

    public var fetchMyRankUseCase: FetchMyRankUseCase {
        FetchMyRankUseCase(rankingRepository: dataContainer.rankingRepository)
    }

    public var fetchRecentFeedUseCase: FetchRecentFeedUseCase {
        FetchRecentFeedUseCase(feedRepository: dataContainer.feedRepository)
    }

    // MARK: - 뱃지 / 지역 / 태그 / 후기 / 앱 정보

    public var fetchMyBadgesUseCase: FetchMyBadgesUseCase {
        FetchMyBadgesUseCase(badgeRepository: dataContainer.badgeRepository)
    }

    public var fetchSeasonalBadgesUseCase: FetchSeasonalBadgesUseCase {
        FetchSeasonalBadgesUseCase(badgeRepository: dataContainer.badgeRepository)
    }

    public var fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase {
        FetchGrowthRegionsUseCase(regionRepository: dataContainer.regionRepository)
    }

    public var fetchRegionDetailUseCase: FetchRegionDetailUseCase {
        FetchRegionDetailUseCase(regionRepository: dataContainer.regionRepository)
    }

    public var fetchCurationTagsUseCase: FetchCurationTagsUseCase {
        FetchCurationTagsUseCase(tagRepository: dataContainer.tagRepository)
    }

    public var fetchPlacesByTagUseCase: FetchPlacesByTagUseCase {
        FetchPlacesByTagUseCase(tagRepository: dataContainer.tagRepository)
    }

    public var fetchSearchablePlacesUseCase: FetchSearchablePlacesUseCase {
        FetchSearchablePlacesUseCase(tagRepository: dataContainer.tagRepository)
    }

    public var createReviewUseCase: CreateReviewUseCase {
        CreateReviewUseCase(reviewRepository: dataContainer.reviewRepository)
    }

    public var fetchPlaceReviewsUseCase: FetchPlaceReviewsUseCase {
        FetchPlaceReviewsUseCase(reviewRepository: dataContainer.reviewRepository)
    }

    public var fetchAppInfoUseCase: FetchAppInfoUseCase {
        FetchAppInfoUseCase(appRepository: dataContainer.appRepository)
    }
}

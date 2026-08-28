//
//  PassportViewModel.swift
//  Presentation
//
//  여권 본체와 뱃지를 함께 불러온다. 여권이 없으면 화면이 성립하지 않지만
//  뱃지는 곁다리라, 뱃지만 실패하면 그 섹션만 비운다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class PassportViewModel {
    public private(set) var passport: Passport?
    public private(set) var badges: [Badge] = []
    public private(set) var isLoading = false
    public var errorMessage: String?

    private var hasLoaded = false

    private let userId: String
    private let fetchPassportUseCase: FetchPassportUseCase
    private let fetchMyBadgesUseCase: FetchMyBadgesUseCase

    public init(
        userId: String,
        fetchPassportUseCase: FetchPassportUseCase,
        fetchMyBadgesUseCase: FetchMyBadgesUseCase
    ) {
        self.userId = userId
        self.fetchPassportUseCase = fetchPassportUseCase
        self.fetchMyBadgesUseCase = fetchMyBadgesUseCase
    }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        async let badges = Self.loadBadges(fetchMyBadgesUseCase)

        do throws(NetworkError) {
            passport = try await fetchPassportUseCase.execute(userId: userId)
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }

        self.badges = await badges
    }

    public func retry() async {
        errorMessage = nil
        await load()
    }

    // MARK: - 화면이 그리는 값

    /// 진행 바에 쓰는 0~1. 서버는 0~100 퍼센트로 준다.
    public var progress: Double {
        guard let passport else { return 0 }
        return min(max(passport.completionRate / 100, 0), 1)
    }

    /// 여권 화면이 보여주는 수집판 — 실제로 찍은 도장만, 최근 방문 순이다.
    /// 아직 못 간 곳은 전체 목록(상세)에서 본다.
    public var collectedStamps: [PassportRegion] {
        allStamps.filter(\.isVisited)
    }

    /// 상세 화면용 전체 수집판. 모은 도장이 앞에 오고, 그 안에서는 최근 방문 순이다.
    public var allStamps: [PassportRegion] {
        guard let passport else { return [] }
        let visited = passport.regions
            .filter(\.isVisited)
            .sorted { ($0.lastVisitedAt ?? .distantPast) > ($1.lastVisitedAt ?? .distantPast) }
        return visited + passport.regions.filter { !$0.isVisited }
    }

    /// 여권 화면이 보여주는 뱃지 — 이미 얻은 것만.
    public var earnedBadges: [Badge] {
        badges.filter(\.isUnlocked)
    }

    /// 상세 화면용 전체 뱃지. 얻은 것이 앞에 온다.
    public var allBadges: [Badge] {
        badges.filter(\.isUnlocked) + badges.filter { !$0.isUnlocked }
    }

    /// 여권 카드 아래 줄 — 가장 최근에 찍은 도장. 한 곳도 없으면 nil이라 줄을 지운다.
    public var lastStamp: String? {
        guard let region = collectedStamps.first,
              let visitedAt = region.lastVisitedAt
        else { return nil }
        return L10n.passportLastStamp(region.displayName, Self.dateFormatter.string(from: visitedAt))
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    private static func loadBadges(_ useCase: FetchMyBadgesUseCase) async -> [Badge] {
        do throws(NetworkError) {
            return try await useCase.execute()
        } catch {
            return []
        }
    }
}

public extension PassportRegion {
    /// 서버는 지역 아이콘을 주지 않는다. 같은 지역이 늘 같은 그림을 갖도록
    /// regionId로 고정 해시를 만들어 지역 아이콘 세트에서 고른다.
    var stampIcon: DSIcon {
        let pool: [DSIcon] = [.temple, .tree, .bridge, .leaf, .sparkles, .cheese, .train, .wind, .baseball, .fish]
        let seed = regionId.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) % 100_003 }
        return pool[abs(seed) % pool.count]
    }
}

public extension Badge {
    var stampIcon: DSIcon { DSIcon(rawValue: icon) ?? .star }

    var isUnlocked: Bool { status == .earned }

    var stateLabel: String {
        switch status {
        case .earned: L10n.passportBadgeEarned
        case .available: L10n.passportBadgeLocked
        case .expired: L10n.passportBadgeOutOfSeason
        }
    }
}

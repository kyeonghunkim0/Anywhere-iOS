//
//  ProfileViewModel.swift
//  Presentation
//
//  프로필 본문(레벨·닉네임)과 통계는 서로 다른 API에서 온다.
//  통계만 실패하면 헤더는 그대로 보여준다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class ProfileViewModel {
    public private(set) var profile: UserProfile?
    public private(set) var stats: ProfileStats?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private var hasLoaded = false

    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let fetchProfileStatsUseCase: FetchProfileStatsUseCase

    public init(
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        fetchProfileStatsUseCase: FetchProfileStatsUseCase
    ) {
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
        self.fetchProfileStatsUseCase = fetchProfileStatsUseCase
    }

    public func load() async {
        guard !hasLoaded else { return }
        await reload()
    }

    /// 편집에서 돌아왔을 때처럼 값이 바뀌었을 수 있는 시점에 다시 읽는다.
    public func reload() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        async let stats = Self.loadStats(fetchProfileStatsUseCase)

        do throws(AuthError) {
            profile = try await fetchMyProfileUseCase.execute()
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }

        self.stats = await stats
    }

    /// "2026.03 가입".
    public var joinedLabel: String? {
        guard let joinedAt = stats?.joinedAt else { return nil }
        return Self.joinedFormatter.string(from: joinedAt)
    }

    private static let joinedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }()

    private static func loadStats(_ useCase: FetchProfileStatsUseCase) async -> ProfileStats? {
        do throws(NetworkError) {
            return try await useCase.execute()
        } catch {
            return nil
        }
    }
}

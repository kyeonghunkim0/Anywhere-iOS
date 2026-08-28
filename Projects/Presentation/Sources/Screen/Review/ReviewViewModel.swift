//
//  ReviewViewModel.swift
//  Presentation
//
//  한 줄 후기 작성. 서버는 500자까지 받지만 프로토타입이 정한 80자를 그대로 지킨다 —
//  "다음 사람에게 딱 한마디"라는 화면의 성격이 길이 제한에서 나온다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class ReviewViewModel {
    public static let maxLength = 80

    public var text = "" {
        didSet {
            guard text.count > Self.maxLength else { return }
            text = String(text.prefix(Self.maxLength))
        }
    }
    public private(set) var isWorking = false
    public var errorMessage: String?

    private let place: PlaceRef
    private let createReviewUseCase: CreateReviewUseCase

    public init(place: PlaceRef, createReviewUseCase: CreateReviewUseCase) {
        self.place = place
        self.createReviewUseCase = createReviewUseCase
    }

    public var placeName: String { place.name }
    public var counter: String { "\(text.count)/\(Self.maxLength)" }
    public var canSubmit: Bool { !trimmedText.isEmpty && !isWorking }

    /// 등록 성공하면 true — 호출부가 화면을 닫는다.
    public func submit() async -> Bool {
        guard canSubmit else { return false }
        isWorking = true
        defer { isWorking = false }

        do throws(ReviewError) {
            _ = try await createReviewUseCase.execute(placeId: place.id, content: trimmedText)
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func message(for error: ReviewError) -> String {
        switch error {
        case .rejected(let message), .placeNotFound(let message):
            message
        case .network:
            L10n.loginNetworkError
        }
    }
}

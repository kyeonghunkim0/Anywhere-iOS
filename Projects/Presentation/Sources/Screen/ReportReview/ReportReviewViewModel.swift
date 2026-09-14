//
//  ReportReviewViewModel.swift
//  Presentation
//
//  사유 4개 중 하나를 고르고(ETC만 상세 사유 필수), 제출한다.
//  이미 신고한 후기를 다시 신고하면 서버가 409를 주는데, 화면 입장에서는 "신고 접수"와
//  같은 결과라 실패로 보여주지 않는다 — .alreadyReported도 성공 취급한다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class ReportReviewViewModel {
    public var selectedReason: ReportReason?
    public var detail = ""
    public private(set) var isWorking = false
    public private(set) var isSubmitted = false
    public var errorMessage: String?

    private let reviewId: String
    private let reportReviewUseCase: ReportReviewUseCase

    public init(reviewId: String, reportReviewUseCase: ReportReviewUseCase) {
        self.reviewId = reviewId
        self.reportReviewUseCase = reportReviewUseCase
    }

    public var canSubmit: Bool {
        guard let selectedReason, !isWorking else { return false }
        guard selectedReason == .etc else { return true }
        return !trimmedDetail.isEmpty
    }

    public func submit() async {
        guard let selectedReason, canSubmit else { return }
        isWorking = true
        defer { isWorking = false }

        do throws(ReviewError) {
            try await reportReviewUseCase.execute(
                reviewId: reviewId,
                reason: selectedReason,
                detail: selectedReason == .etc ? trimmedDetail : nil
            )
            isSubmitted = true
        } catch .alreadyReported {
            isSubmitted = true
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    private var trimmedDetail: String {
        detail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func message(for error: ReviewError) -> String {
        switch error {
        case .rejected(let message), .placeNotFound(let message):
            message
        case .alreadyReported:
            ""
        case .network:
            L10n.loginNetworkError
        }
    }
}

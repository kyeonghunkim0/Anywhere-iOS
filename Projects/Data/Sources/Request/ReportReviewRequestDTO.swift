struct ReportReviewRequestDTO: Encodable, Sendable {
    let reason: String
    let detail: String?
}

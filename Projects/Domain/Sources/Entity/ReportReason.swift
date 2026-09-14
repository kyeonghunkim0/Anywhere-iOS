public enum ReportReason: String, CaseIterable, Sendable {
    case spam = "SPAM"
    case abuse = "ABUSE"
    case inappropriate = "INAPPROPRIATE"
    case etc = "ETC"
}

public struct CheckInResult: Sendable {
    public let message: String
    public let stamp: StampResult

    public init(message: String, stamp: StampResult) {
        self.message = message
        self.stamp = stamp
    }
}

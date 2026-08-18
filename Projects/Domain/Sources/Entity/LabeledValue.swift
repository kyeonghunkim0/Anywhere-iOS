/// 서버가 label과 표시 문자열을 함께 내려주는 요약 지표 한 줄.
/// (users/{id}/detail의 dash, regions/{id}의 stats — 값이 숫자로 올 수도 문자열로 올 수도 있어
/// Data 계층에서 문자열로 통일한다.)
public struct LabeledValue: Sendable, Identifiable, Equatable {
    public var id: String { label }
    public let label: String
    public let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

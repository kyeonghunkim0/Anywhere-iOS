/// 서버가 value를 문자열로도 숫자로도 내려준다 (users detail의 dash, region detail의 stats).
/// 표시용 값이므로 여기서 문자열로 통일한다.
struct LabeledValueDTO: Decodable, Sendable {
    let label: String
    let value: String

    private enum CodingKeys: String, CodingKey {
        case label, value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decode(String.self, forKey: .label)
        if let text = try? container.decode(String.self, forKey: .value) {
            value = text
        } else {
            let number = try container.decode(Double.self, forKey: .value)
            value = number == number.rounded() ? String(Int(number)) : String(number)
        }
    }
}

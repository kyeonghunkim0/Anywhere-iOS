enum RequestTask: Sendable {
    case plain
    case jsonBody(any Encodable & Sendable)
}

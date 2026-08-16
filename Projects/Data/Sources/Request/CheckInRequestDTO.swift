struct CheckInRequestDTO: Encodable, Sendable {
    let placeId: String
    let lat: Double
    let lng: Double
}

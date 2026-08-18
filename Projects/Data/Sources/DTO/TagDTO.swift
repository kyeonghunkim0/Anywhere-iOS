/// GET /api/tags.
struct CurationTagDTO: Decodable, Sendable {
    let id: String
    let label: String
    let emoji: String?
    let placeCount: Int
}

import Domain

extension CurationTagDTO {
    func toEntity() -> CurationTag {
        CurationTag(id: id, label: label, emoji: emoji, placeCount: placeCount)
    }
}

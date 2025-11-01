
extension Integer: Decodable {
    
    @inlinable
    public init(from decoder: any Decoder) throws {
        let words = try decoder.singleValueContainer().decode([UInt].self)
        guard !words.isEmpty else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot initialize Integer from an empty array of words."
                )
            )
        }
        self._words = words
        self._standardize()
    }
}

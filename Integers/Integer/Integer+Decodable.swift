
extension Integer: Decodable {
    
    @inlinable
    public init(from decoder: any Decoder) throws {
        self.init(_words: try decoder.singleValueContainer().decode([UInt].self))
    }
}

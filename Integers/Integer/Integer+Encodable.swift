
extension Integer: Encodable {
    
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(_words)
    }
}


extension Integer: Equatable {
    
    @inlinable
    public static func == (lhs: Integer, rhs: Integer) -> Bool {
        return lhs._words == rhs._words
    }
}

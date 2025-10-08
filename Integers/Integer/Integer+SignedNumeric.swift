
extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public mutating func negate() {
        fatalError()
    }
}


extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public mutating func negate() {
        var borrow = false
        for index in _words.indices {
            (_words[index], borrow) = (0 as UInt)._subtractingReportingOverflow(_words[index], borrowing: borrow)
        }
        if borrow {
            _words.reserveCapacity(_words.count + 1)
            _words.append(.max)
        }
        _normalize()
    }
}


extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public mutating func negate() {
        var overflow = false
        for (index, word) in _words.enumerated() {
            (_words[index], overflow) = (0 as UInt)._subtractingReportingOverflow(word, borrowing: overflow)
        }
        if overflow {
            _words.reserveCapacity(_words.count + 1)
            _words.append(.max)
        }
        _normalize()
    }
}


extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public mutating func negate() {
        var overflow = false
        for index in _words.indices {
            (_words[index], overflow) = UInt.min._subtractingReportingOverflow(_words[index], borrowing: overflow)
        }
        if overflow {
            _words.reserveCapacity(_words.count + 1)
            _words.append(UInt.min)
        }
        _standardize()
    }
}

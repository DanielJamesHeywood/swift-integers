
extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public mutating func negate() {
        var (partialValue, overflow) = (UInt.min, false)
        for index in _words.indices {
            if overflow {
                (partialValue, overflow) = UInt.min.subtractingReportingOverflow(_words[index])
                if overflow {
                    partialValue &-= 1
                } else {
                    (partialValue, overflow) = partialValue.subtractingReportingOverflow(1)
                }
            } else {
                (partialValue, overflow) = UInt.min.subtractingReportingOverflow(_words[index])
            }
            _words[index] = partialValue
        }
        if overflow {
            _words.reserveCapacity(_words.count + 1)
            _words.append(UInt.min)
        }
        _standardize()
    }
}

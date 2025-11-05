
extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: operand._words.count + 1,
                initializingWith: { buffer, initializedCount in
                    var borrow = false
                    for (index, word) in operand._words.enumerated() {
                        let (partialValue, overflow) = (0 as UInt)._subtractingReportingOverflow(word, borrowing: borrow)
                        buffer.initializeElement(at: index, to: partialValue)
                        borrow = overflow
                    }
                    if borrow {
                        buffer.initializeElement(at: operand._words.count, to: .max)
                        initializedCount = operand._words.count + 1
                    } else {
                        initializedCount = operand._words.count
                    }
                }
            )
        )
    }
    
    @inlinable
    public mutating func negate() {
        var borrow = false
        for index in _words.indices {
            let (partialValue, overflow) = (0 as UInt)._subtractingReportingOverflow(_words[index], borrowing: borrow)
            _words[index] = partialValue
            borrow = overflow
        }
        if borrow {
            _words.reserveCapacity(_words.count + 1)
            _words.append(.max)
        }
        _normalize()
    }
}

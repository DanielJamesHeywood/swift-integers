
extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        let words = operand._words
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: words.count + 1,
                initializingWith: { buffer, initializedCount in
                    var partialValue: UInt = 0
                    var overflow = false
                    for index in words.indices {
                        if overflow {
                            (partialValue, overflow) = (0 as UInt).subtractingReportingOverflow(words[index])
                            if overflow {
                                partialValue &-= 1
                            } else {
                                (partialValue, overflow) = partialValue.subtractingReportingOverflow(1)
                            }
                        } else {
                            (partialValue, overflow) = (0 as UInt).subtractingReportingOverflow(words[index])
                        }
                        buffer.initializeElement(at: index, to: partialValue)
                    }
                    if overflow {
                        buffer.initializeElement(at: words.count, to: 0)
                        initializedCount = words.count + 1
                    } else {
                        initializedCount = words.count
                    }
                }
            )
        )
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
            _words.append(UInt.min)
        }
    }
}


@frozen
public struct Integer {
    
    @usableFromInline
    internal var _words: [UInt]
    
    @inlinable
    internal mutating func _standardize() {
        if _words.last == .min {
            repeat {
                _words.removeLast()
            } while _words.last == .min
            if _words.last?.leadingZeroBitCount == 0 {
                _words.append(.min)
            }
        }
        if _words.last == .max {
            repeat {
                _words.removeLast()
            } while _words.last == .max
            if _words.last?.leadingZeroBitCount != 0 {
                _words.append(.max)
            }
        }
    }
}

extension Integer {
    
    @inlinable
    internal var _isNegative: Bool {
        return _words.last.unsafelyUnwrapped.leadingZeroBitCount == 0
    }
}

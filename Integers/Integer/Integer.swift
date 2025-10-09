
@frozen
public struct Integer {
    
    @usableFromInline
    internal var _words: [UInt]
    
    @inlinable
    internal init(_words: [UInt]) {
        precondition(!_words.isEmpty)
        self._words = _words
        self._standardize()
    }
    
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

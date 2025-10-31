
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
        if _words.last.unsafelyUnwrapped == .min {
            repeat {
                _words.removeLast()
            } while _words.last == .min
            if let lastWord = _words.last {
                if lastWord.leadingZeroBitCount == 0 {
                    _words.append(.min)
                }
            } else {
                _words = [.min]
            }
        }
        if _words.last.unsafelyUnwrapped == .max {
            repeat {
                _words.removeLast()
            } while _words.last == .max
            if let lastWord = _words.last {
                if lastWord.leadingZeroBitCount != 0 {
                    _words.append(.max)
                }
            } else {
                _words = [.max]
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

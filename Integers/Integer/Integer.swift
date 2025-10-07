
@frozen
public struct Integer {
    
    @usableFromInline
    internal var _words: [UInt]
    
    @inlinable
    internal init(_words: [UInt]) {
        self._words = _words
        _standardize()
    }
    
    @inlinable
    internal func _standardize() {
        fatalError()
    }
}

extension Integer {
    
    @inlinable
    internal var _isNegative: Bool {
        return _words.last.unsafelyUnwrapped.leadingZeroBitCount == 0
    }
}

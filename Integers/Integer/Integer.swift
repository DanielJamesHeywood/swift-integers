
@frozen
public struct Integer {
    
    @usableFromInline
    internal var _words: [UInt]
}

extension Integer {
    
    @inlinable
    internal var _isNegative: Bool {
        return _words.last.unsafelyUnwrapped.leadingZeroBitCount == 0
    }
}

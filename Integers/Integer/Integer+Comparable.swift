
extension Integer: Comparable {
    
    @inlinable
    public static func < (lhs: Integer, rhs: Integer) -> Bool {
        return lhs._compare(to: rhs) == .lessThan
    }
    
    @inlinable
    public static func <= (lhs: Integer, rhs: Integer) -> Bool {
        return lhs._compare(to: rhs) != .greaterThan
    }
    
    @inlinable
    public static func >= (lhs: Integer, rhs: Integer) -> Bool {
        return lhs._compare(to: rhs) != .lessThan
    }
    
    @inlinable
    public static func > (lhs: Integer, rhs: Integer) -> Bool {
        return lhs._compare(to: rhs) == .greaterThan
    }
}

extension Integer {
    
    @frozen
    @usableFromInline
    internal enum _ComparisonResult {
        case lessThan
        case greaterThan
        case equalTo
    }
    
    @inlinable
    internal func _compare(to other: Integer) -> _ComparisonResult {
        fatalError()
    }
}

extension Integer {
    
    @inlinable
    internal var _isNegative: Bool {
        return _words.last.unsafelyUnwrapped.leadingZeroBitCount == 0
    }
}

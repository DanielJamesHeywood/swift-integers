
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
        switch (_isNegative, other._isNegative) {
        case (false, false):
            return _unsignedCompare(to: other)
        case (false, true):
            return .greaterThan
        case (true, false):
            return .lessThan
        case (true, true):
            switch _unsignedCompare(to: other) {
            case .lessThan:
                return .greaterThan
            case .greaterThan:
                return .lessThan
            case .equalTo:
                return .equalTo
            }
        }
    }
    
    @inlinable
    internal func _unsignedCompare(to other: Integer) -> _ComparisonResult {
        guard _words.count == other._words.count else {
            return _words.count < other._words.count ? .lessThan : .greaterThan
        }
        for index in _words.indices.reversed() {
            let word = _words[index], otherWord = other._words[index]
            guard word == otherWord else {
                return word < otherWord ? .lessThan : .greaterThan
            }
        }
        return .equalTo
    }
}

extension Integer {
    
    @inlinable
    internal var _isNegative: Bool {
        return _words.last.unsafelyUnwrapped.leadingZeroBitCount == 0
    }
}

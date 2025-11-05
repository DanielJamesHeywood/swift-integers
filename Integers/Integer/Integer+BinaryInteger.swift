
extension Integer: BinaryInteger {
    
    @inlinable
    public static var isSigned: Bool {
        return true
    }
    
    @inlinable
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        fatalError()
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ source: T) {
        fatalError()
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ source: T) {
        fatalError()
    }
    
    @inlinable
    public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
        self.init(source)
    }
    
    @inlinable
    public init<T: BinaryInteger>(clamping source: T) {
        self.init(source)
    }
    
    public typealias Words = [UInt]
    
    @inlinable
    public var words: [UInt] {
        return _words
    }
    
    @inlinable
    public var bitWidth: Int {
        return _words.count * UInt.bitWidth
    }
    
    @inlinable
    public var trailingZeroBitCount: Int {
        guard let index = _words.firstIndex(
            where: { word in
                return word != 0
            }
        ) else {
            return UInt.bitWidth
        }
        return index * UInt.bitWidth + _words[index].trailingZeroBitCount
    }
    
    @inlinable
    public static func / (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func /= (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
    
    @inlinable
    public static func % (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func %= (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
    
    @inlinable
    public static func + (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func += (lhs: inout Integer, rhs: Integer) {
        var carry = false
        for (index, rhWord) in rhs._words.prefix(lhs._words.count).enumerated() {
            let (partialValue, overflow) = lhs._words[index]._addingReportingOverflow(rhWord, carrying: carry)
            lhs._words[index] = partialValue
            carry = overflow
        }
        lhs._normalize()
        fatalError()
    }
    
    @inlinable
    public static func - (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func -= (lhs: inout Integer, rhs: Integer) {
        var borrow = false
        for (index, rhWord) in rhs._words.prefix(lhs._words.count).enumerated() {
            let (partialValue, overflow) = lhs._words[index]._subtractingReportingOverflow(rhWord, borrowing: borrow)
            lhs._words[index] = partialValue
            borrow = overflow
        }
        lhs._normalize()
        fatalError()
    }
    
    @inlinable
    public static func * (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func *= (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
    
    @inlinable
    public prefix static func ~ (x: Integer) -> Integer {
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: x._words.count,
                initializingWith: { buffer, initializedCount in
                    for (index, word) in x._words.enumerated() {
                        buffer.initializeElement(at: index, to: ~word)
                    }
                    initializedCount = x._words.count
                }
            )
        )
    }
    
    @inlinable
    public static func & (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func &= (lhs: inout Integer, rhs: Integer) {
        for (index, rhWord) in rhs._words.prefix(lhs._words.count).enumerated() {
            lhs._words[index] &= rhWord
        }
        lhs._normalize()
        fatalError()
    }
    
    @inlinable
    public static func | (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func |= (lhs: inout Integer, rhs: Integer) {
        for (index, rhWord) in rhs._words.prefix(lhs._words.count).enumerated() {
            lhs._words[index] |= rhWord
        }
        lhs._normalize()
        fatalError()
    }
    
    @inlinable
    public static func ^ (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func ^= (lhs: inout Integer, rhs: Integer) {
        for (index, rhWord) in rhs._words.prefix(lhs._words.count).enumerated() {
            lhs._words[index] ^= rhWord
        }
        fatalError()
    }
    
    @inlinable
    public static func >> <RHS: BinaryInteger>(lhs: Integer, rhs: RHS) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func >>= <RHS: BinaryInteger>(lhs: inout Integer, rhs: RHS) {
        fatalError()
    }
    
    @inlinable
    public static func << <RHS: BinaryInteger>(lhs: Integer, rhs: RHS) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func <<= <RHS: BinaryInteger>(lhs: inout Integer, rhs: RHS) {
        fatalError()
    }
    
    @inlinable
    public func quotientAndRemainder(dividingBy rhs: Integer) -> (quotient: Integer, remainder: Integer) {
        fatalError()
    }
    
    @inlinable
    public func isMultiple(of other: Integer) -> Bool {
        fatalError()
    }
    
    @inlinable
    public func signum() -> Integer {
        return _isNegative ? -1 : _isZero ? 0 : 1
    }
}

extension FixedWidthInteger {
    
    @inlinable
    internal func _addingReportingOverflow(_ rhs: Self, carrying: Bool) -> (partialValue: Self, overflow: Bool) {
        guard carrying else {
            return addingReportingOverflow(rhs)
        }
        let (partialValue, overflow) = addingReportingOverflow(rhs)
        return overflow ? (partialValue &+ 1, true) : partialValue.addingReportingOverflow(1)
    }
    
    @inlinable
    internal func _subtractingReportingOverflow(_ rhs: Self, borrowing: Bool) -> (partialValue: Self, overflow: Bool) {
        guard borrowing else {
            return subtractingReportingOverflow(rhs)
        }
        let (partialValue, overflow) = subtractingReportingOverflow(rhs)
        return overflow ? (partialValue &- 1, true) : partialValue.subtractingReportingOverflow(1)
    }
}

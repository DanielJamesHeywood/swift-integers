
extension Integer: BinaryInteger {
    
    @inlinable
    public static var isSigned: Bool {
        return true
    }
    
    @inlinable
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard source.isFinite else {
            return nil
        }
        if source.isZero {
            self = 0
        } else {
            guard source.significandWidth <= source.exponent else {
                return nil
            }
            let significandShift = source.exponent - T.Exponent(source.significandWidth &+ source.significandBitPattern.trailingZeroBitCount)
            var integer = 1 << source.exponent | Integer(source.significandBitPattern) << significandShift
            if source < 0 {
                integer.negate()
            }
            self = integer
        }
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ source: T) {
        guard source.isFinite else {
            preconditionFailure()
        }
        if source.isZero {
            self = 0
        } else {
            let significandShift = source.exponent - T.Exponent(source.significandWidth &+ source.significandBitPattern.trailingZeroBitCount)
            var integer = 1 << source.exponent | Integer(source.significandBitPattern) << significandShift
            if source < 0 {
                integer.negate()
            }
            self = integer
        }
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
        let wordCount = Swift.max(lhs._words.count, rhs._words.count)
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount + 1,
                initializingWith: { buffer, initializedCount in
                    var carry = false
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        let (partialValue, overflow) = lhWord._addingReportingOverflow(rhWord, carrying: carry)
                        buffer.initializeElement(at: index, to: partialValue)
                        carry = overflow
                    }
                    fatalError()
                }
            )
        )
    }
    
    @inlinable
    public static func += (lhs: inout Integer, rhs: Integer) {
        var carry = false
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            let (partialValue, overflow) = lhs._words[index]._addingReportingOverflow(rhWord, carrying: carry)
            lhs._words[index] = partialValue
            carry = overflow
        }
        lhs._normalize()
    }
    
    @inlinable
    public static func - (lhs: Integer, rhs: Integer) -> Integer {
        let wordCount = Swift.max(lhs._words.count, rhs._words.count)
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount + 1,
                initializingWith: { buffer, initializedCount in
                    var borrow = false
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        let (partialValue, overflow) = lhWord._subtractingReportingOverflow(rhWord, borrowing: borrow)
                        buffer.initializeElement(at: index, to: partialValue)
                        borrow = overflow
                    }
                    fatalError()
                }
            )
        )
    }
    
    @inlinable
    public static func -= (lhs: inout Integer, rhs: Integer) {
        var borrow = false
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            let (partialValue, overflow) = lhs._words[index]._subtractingReportingOverflow(rhWord, borrowing: borrow)
            lhs._words[index] = partialValue
            borrow = overflow
        }
        lhs._normalize()
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
        return x ^ -1
    }
    
    @inlinable
    public static func & (lhs: Integer, rhs: Integer) -> Integer {
        var wordCount = Swift.min(lhs._words.count, rhs._words.count)
        if lhs._words.count > rhs._words.count && rhs._isNegative {
            wordCount = lhs._words.count
        }
        if lhs._words.count < rhs._words.count && lhs._isNegative {
            wordCount = rhs._words.count
        }
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount,
                initializingWith: { buffer, initializedCount in
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        buffer.initializeElement(at: index, to: lhWord & rhWord)
                    }
                    if lhs._words.count > rhs._words.count && rhs._isNegative {
                        let lhRemainingWords = lhs._words.suffix(from: rhs._words.endIndex)
                        buffer._initializeElements(startingAt: rhs._words.endIndex, toContentsOf: lhRemainingWords)
                    }
                    if lhs._words.count < rhs._words.count && lhs._isNegative {
                        let rhRemainingWords = rhs._words.suffix(from: lhs._words.endIndex)
                        buffer._initializeElements(startingAt: lhs._words.endIndex, toContentsOf: rhRemainingWords)
                    }
                    initializedCount = wordCount
                }
            )
        )
    }
    
    @inlinable
    public static func &= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            lhs._words[index] &= rhWord
        }
        if lhs._words.count > rhs._words.count && !rhsIsNegative {
            lhs._words.removeLast(lhs._words.count - rhs._words.count)
        }
        if lhs._words.count < rhs._words.count && lhsIsNegative {
            lhs._words.append(contentsOf: rhs._words.suffix(from: lhs._words.endIndex))
        }
        lhs._normalize()
    }
    
    @inlinable
    public static func | (lhs: Integer, rhs: Integer) -> Integer {
        var wordCount = Swift.min(lhs._words.count, rhs._words.count)
        if lhs._words.count > rhs._words.count && !rhs._isNegative {
            wordCount = lhs._words.count
        }
        if lhs._words.count < rhs._words.count && !lhs._isNegative {
            wordCount = rhs._words.count
        }
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount,
                initializingWith: { buffer, initializedCount in
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        buffer.initializeElement(at: index, to: lhWord | rhWord)
                    }
                    if lhs._words.count > rhs._words.count && !rhs._isNegative {
                        let lhRemainingWords = lhs._words.suffix(from: rhs._words.endIndex)
                        buffer._initializeElements(startingAt: rhs._words.endIndex, toContentsOf: lhRemainingWords)
                    }
                    if lhs._words.count < rhs._words.count && !lhs._isNegative {
                        let rhRemainingWords = rhs._words.suffix(from: lhs._words.endIndex)
                        buffer._initializeElements(startingAt: lhs._words.endIndex, toContentsOf: rhRemainingWords)
                    }
                    initializedCount = wordCount
                }
            )
        )
    }
    
    @inlinable
    public static func |= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            lhs._words[index] |= rhWord
        }
        if lhs._words.count > rhs._words.count && rhsIsNegative {
            lhs._words.removeLast(lhs._words.count - rhs._words.count)
        }
        if lhs._words.count < rhs._words.count && !lhsIsNegative {
            lhs._words.append(contentsOf: rhs._words.suffix(from: lhs._words.endIndex))
        }
        lhs._normalize()
    }
    
    @inlinable
    public static func ^ (lhs: Integer, rhs: Integer) -> Integer {
        let wordCount = Swift.max(lhs._words.count, rhs._words.count)
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount,
                initializingWith: { buffer, initializedCount in
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        buffer.initializeElement(at: index, to: lhWord ^ rhWord)
                    }
                    if lhs._words.count > rhs._words.count {
                        let lhRemainingWords = lhs._words.suffix(from: rhs._words.endIndex)
                        if rhs._isNegative {
                            for (index, lhWord) in lhRemainingWords._enumeratedWithIndices() {
                                buffer.initializeElement(at: index, to: ~lhWord)
                            }
                        } else {
                            buffer._initializeElements(startingAt: rhs._words.endIndex, toContentsOf: lhRemainingWords)
                        }
                    }
                    if lhs._words.count < rhs._words.count {
                        let rhRemainingWords = rhs._words.suffix(from: lhs._words.endIndex)
                        if lhs._isNegative {
                            for (index, rhWord) in rhRemainingWords._enumeratedWithIndices() {
                                buffer.initializeElement(at: index, to: ~rhWord)
                            }
                        } else {
                            buffer._initializeElements(startingAt: lhs._words.endIndex, toContentsOf: rhRemainingWords)
                        }
                    }
                    initializedCount = wordCount
                }
            )
        )
    }
    
    @inlinable
    public static func ^= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            lhs._words[index] ^= rhWord
        }
        if lhs._words.count > rhs._words.count {}
        if lhs._words.count < rhs._words.count {}
        lhs._normalize()
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

extension Collection {
    
    @inlinable
    internal func _enumeratedWithIndices() -> Zip2Sequence<Indices, Self> {
        return zip(indices, self)
    }
}

extension UnsafeMutableBufferPointer {
    
    @inlinable
    internal func _initializeElements(startingAt index: Index, toContentsOf source: some Collection<Element>) {
        precondition(startIndex <= index && index + source.count <= endIndex)
        _ = suffix(from: index).initialize(fromContentsOf: source)
    }
}

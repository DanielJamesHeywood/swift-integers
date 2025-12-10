
@frozen
public struct Integer {
    
    @usableFromInline
    internal var _words: [UInt]
    
    @inlinable
    internal init(_words: [UInt]) {
        precondition(!_words.isEmpty)
        self._words = _words
        self._normalize()
    }
    
    @inlinable
    internal mutating func _normalize() {
        if _words.last.unsafelyUnwrapped == UInt.min {
            repeat {
                _words.removeLast()
            } while _words.last == UInt.min
            if let lastWord = _words.last {
                if lastWord.leadingZeroBitCount == 0 {
                    _words.append(UInt.min)
                }
            } else {
                _words = [UInt.min]
            }
        }
        if _words.last.unsafelyUnwrapped == UInt.max {
            repeat {
                _words.removeLast()
            } while _words.last == UInt.max
            if let lastWord = _words.last {
                if lastWord.leadingZeroBitCount != 0 {
                    _words.append(UInt.max)
                }
            } else {
                _words = [UInt.max]
            }
        }
    }
}

extension Integer {
    
    @inlinable
    internal var _isNegative: Bool { _words.last.unsafelyUnwrapped.leadingZeroBitCount == 0 }
    
    @inlinable
    internal var _isZero: Bool { _words == [0] }
}

extension Integer {
    
    @inlinable
    internal var _signExtendingWord: UInt { _isNegative ? UInt.max : UInt.min }
}

extension Integer: AdditiveArithmetic {
    
    @inlinable
    public static var zero: Integer { 0 }
}

extension Integer: Numeric {
    
    @inlinable
    public init?<T: BinaryInteger>(exactly source: T) {
        self.init(source)
    }
    
    public typealias Magnitude = Integer
    
    @inlinable
    public var magnitude: Integer { _isNegative ? -self : self }
}

extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer { 0 - operand }
    
    @inlinable
    public mutating func negate() {
        let isNegative = _isNegative
        guard !_isZero else {
            return
        }
        if isNegative {
            _words.reserveCapacity(_words.count + 1)
        }
        var borrow = false
        for index in _words.indices {
            let (partialValue, overflow) = UInt.min._subtractingReportingOverflow(_words[index], borrowing: borrow)
            _words[index] = partialValue
            borrow = overflow
        }
        if isNegative {
            _words.append(UInt.max)
        }
        _normalize()
    }
}

extension Integer: Strideable {
    
    public typealias Stride = Integer
    
    @inlinable
    public func distance(to other: Integer) -> Integer { other - self }
    
    @inlinable
    public func advanced(by n: Integer) -> Integer { self + n }
}

extension Integer: BinaryInteger {
    
    @inlinable
    public static var isSigned: Bool { true }
    
    @inlinable
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard let integer = source._convertExactlyToInteger() else { return nil }
        self = integer
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ source: T) {
        self = source._convertToInteger()
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ source: T) {
        self.init(
            _words: !T.isSigned && source.words.last.unsafelyUnwrapped.leadingZeroBitCount == 0 ? Array(
                unsafeUninitializedCapacity: source.words.count + 1,
                initializingWith: { buffer, initializedCount in
                    buffer._initializeElements(startingAt: 0, toContentsOf: source.words)
                    buffer.initializeElement(at: source.words.count, to: 0)
                    initializedCount = buffer.count
                }
            ) : Array(source.words)
        )
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
    public var words: [UInt] { _words }
    
    @inlinable
    public var bitWidth: Int { _words.count * UInt.bitWidth }
    
    @inlinable
    public var trailingZeroBitCount: Int {
        guard let index = _words.firstIndex(where: { word in word != 0 }) else { return UInt.bitWidth }
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
        guard lhs != 0 else { return rhs }
        guard rhs != 0 else { return lhs }
        let maxWordCount = Swift.max(lhs._words.count, rhs._words.count)
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: lhs._isNegative != rhs._isNegative ? maxWordCount : maxWordCount + 1,
                initializingWith: { buffer, initializedCount in
                    var carry = false
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        let (partialValue, overflow) = lhWord._addingReportingOverflow(rhWord, carrying: carry)
                        buffer.initializeElement(at: index, to: partialValue)
                        carry = overflow
                    }
                    if lhs._words.count > rhs._words.count {
                        let rhWord = rhs._signExtendingWord
                        for (index, lhWord) in lhs._words.suffix(from: rhs._words.endIndex)._enumeratedWithIndices() {
                            let (partialValue, overflow) = lhWord._addingReportingOverflow(rhWord, carrying: carry)
                            buffer.initializeElement(at: index, to: partialValue)
                            carry = overflow
                        }
                    }
                    if lhs._words.count < rhs._words.count {
                        let lhWord = lhs._signExtendingWord
                        for (index, rhWord) in rhs._words.suffix(from: lhs._words.endIndex)._enumeratedWithIndices() {
                            let (partialValue, overflow) = lhWord._addingReportingOverflow(rhWord, carrying: carry)
                            buffer.initializeElement(at: index, to: partialValue)
                            carry = overflow
                        }
                    }
                    if !lhs._isNegative && !rhs._isNegative {
                        buffer.initializeElement(at: maxWordCount, to: UInt.min)
                    }
                    if lhs._isNegative && rhs._isNegative {
                        buffer.initializeElement(at: maxWordCount, to: UInt.max)
                    }
                    initializedCount = buffer.count
                }
            )
        )
    }
    
    @inlinable
    public static func += (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        guard lhs != 0 else {
            lhs = rhs
            return
        }
        guard rhs != 0 else {
            return
        }
        if lhs._words.count < rhs._words.count {
            lhs._words.reserveCapacity(rhs._words.count)
        }
        if lhs._isNegative == rhs._isNegative {
            lhs._words.reserveCapacity(Swift.max(lhs._words.count, rhs._words.count) + 1)
        }
        var carry = false
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            let (partialValue, overflow) = lhs._words[index]._addingReportingOverflow(rhWord, carrying: carry)
            lhs._words[index] = partialValue
            carry = overflow
        }
        if lhs._words.count > rhs._words.count {
            let rhWord = rhsIsNegative ? UInt.max : UInt.min
            for index in lhs._words.indices.suffix(from: rhs._words.endIndex) {
                let (partialValue, overflow) = lhs._words[index]._addingReportingOverflow(rhWord, carrying: carry)
                lhs._words[index] = partialValue
                carry = overflow
            }
        }
        if lhs._words.count < rhs._words.count {
            let lhWord = lhsIsNegative ? UInt.max : UInt.min
            for rhWord in rhs._words.suffix(from: lhs._words.endIndex) {
                let (partialValue, overflow) = lhWord._addingReportingOverflow(rhWord, carrying: carry)
                lhs._words.append(partialValue)
                carry = overflow
            }
        }
        if !lhsIsNegative && !rhsIsNegative {
            lhs._words.append(UInt.min)
        }
        if lhsIsNegative && rhsIsNegative {
            lhs._words.append(UInt.max)
        }
        lhs._normalize()
    }
    
    @inlinable
    public static func - (lhs: Integer, rhs: Integer) -> Integer {
        guard rhs != 0 else { return lhs }
        let maxWordCount = Swift.max(lhs._words.count, rhs._words.count)
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: lhs._isNegative == rhs._isNegative ? maxWordCount : maxWordCount + 1,
                initializingWith: { buffer, initializedCount in
                    var borrow = false
                    for (index, (lhWord, rhWord)) in zip(lhs._words, rhs._words).enumerated() {
                        let (partialValue, overflow) = lhWord._subtractingReportingOverflow(rhWord, borrowing: borrow)
                        buffer.initializeElement(at: index, to: partialValue)
                        borrow = overflow
                    }
                    if lhs._words.count > rhs._words.count {
                        let rhWord = rhs._signExtendingWord
                        for (index, lhWord) in lhs._words.suffix(from: rhs._words.endIndex)._enumeratedWithIndices() {
                            let (partialValue, overflow) = lhWord._subtractingReportingOverflow(rhWord, borrowing: borrow)
                            buffer.initializeElement(at: index, to: partialValue)
                            borrow = overflow
                        }
                    }
                    if lhs._words.count < rhs._words.count {
                        let lhWord = lhs._signExtendingWord
                        for (index, rhWord) in rhs._words.suffix(from: lhs._words.endIndex)._enumeratedWithIndices() {
                            let (partialValue, overflow) = lhWord._subtractingReportingOverflow(rhWord, borrowing: borrow)
                            buffer.initializeElement(at: index, to: partialValue)
                            borrow = overflow
                        }
                    }
                    if !lhs._isNegative && rhs._isNegative {
                        buffer.initializeElement(at: maxWordCount, to: UInt.min)
                    }
                    if lhs._isNegative && !rhs._isNegative {
                        buffer.initializeElement(at: maxWordCount, to: UInt.max)
                    }
                    initializedCount = buffer.count
                }
            )
        )
    }
    
    @inlinable
    public static func -= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        guard rhs != 0 else {
            return
        }
        if lhs._words.count < rhs._words.count {
            lhs._words.reserveCapacity(rhs._words.count)
        }
        if lhs._isNegative != rhs._isNegative {
            lhs._words.reserveCapacity(Swift.max(lhs._words.count, rhs._words.count) + 1)
        }
        var borrow = false
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            let (partialValue, overflow) = lhs._words[index]._subtractingReportingOverflow(rhWord, borrowing: borrow)
            lhs._words[index] = partialValue
            borrow = overflow
        }
        if lhs._words.count > rhs._words.count {
            let rhWord = rhsIsNegative ? UInt.max : UInt.min
            for index in lhs._words.indices.suffix(from: rhs._words.endIndex) {
                let (partialValue, overflow) = lhs._words[index]._subtractingReportingOverflow(rhWord, borrowing: borrow)
                lhs._words[index] = partialValue
                borrow = overflow
            }
        }
        if lhs._words.count < rhs._words.count {
            let lhWord = lhsIsNegative ? UInt.max : UInt.min
            for rhWord in rhs._words.suffix(from: lhs._words.endIndex) {
                let (partialValue, overflow) = lhWord._subtractingReportingOverflow(rhWord, borrowing: borrow)
                lhs._words.append(partialValue)
                borrow = overflow
            }
        }
        if !lhsIsNegative && rhsIsNegative {
            lhs._words.append(UInt.min)
        }
        if lhsIsNegative && !rhsIsNegative {
            lhs._words.append(UInt.max)
        }
        lhs._normalize()
    }
    
    @inlinable
    public static func * (lhs: Integer, rhs: Integer) -> Integer {
        var integer = lhs.magnitude._multipliedUnsigned(by: rhs.magnitude)
        if lhs._isNegative != rhs._isNegative {
            integer.negate()
        }
        return integer
    }
    
    @inlinable
    public static func *= (lhs: inout Integer, rhs: Integer) {
        lhs = lhs * rhs
    }
    
    @inlinable
    public prefix static func ~ (x: Integer) -> Integer { x ^ -1 }
    
    @inlinable
    public static func & (lhs: Integer, rhs: Integer) -> Integer {
        guard rhs != 0, lhs != -1 else { return rhs }
        guard lhs != 0, rhs != -1 else { return lhs }
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
                        buffer._initializeElements(
                            startingAt: rhs._words.endIndex,
                            toContentsOf: lhs._words.suffix(from: rhs._words.endIndex)
                        )
                    }
                    if lhs._words.count < rhs._words.count && lhs._isNegative {
                        buffer._initializeElements(
                            startingAt: lhs._words.endIndex,
                            toContentsOf: rhs._words.suffix(from: lhs._words.endIndex)
                        )
                    }
                    initializedCount = buffer.count
                }
            )
        )
    }
    
    @inlinable
    public static func &= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        guard rhs != 0, lhs != -1 else {
            lhs = rhs
            return
        }
        guard lhs != 0, rhs != -1 else {
            return
        }
        if lhs._words.count < rhs._words.count && lhsIsNegative {
            lhs._words.reserveCapacity(rhs._words.count)
        }
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
        guard lhs != 0, rhs != -1 else { return rhs }
        guard rhs != 0, lhs != -1 else { return lhs }
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
                        buffer._initializeElements(
                            startingAt: rhs._words.endIndex,
                            toContentsOf: lhs._words.suffix(from: rhs._words.endIndex)
                        )
                    }
                    if lhs._words.count < rhs._words.count && !lhs._isNegative {
                        buffer._initializeElements(
                            startingAt: lhs._words.endIndex,
                            toContentsOf: rhs._words.suffix(from: lhs._words.endIndex)
                        )
                    }
                    initializedCount = buffer.count
                }
            )
        )
    }
    
    @inlinable
    public static func |= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        guard lhs != 0, rhs != -1 else {
            lhs = rhs
            return
        }
        guard rhs != 0, lhs != -1 else {
            return
        }
        if lhs._words.count < rhs._words.count && !lhsIsNegative {
            lhs._words.reserveCapacity(rhs._words.count)
        }
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
        guard lhs != 0 else { return rhs }
        guard rhs != 0 else { return lhs }
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: Swift.max(lhs._words.count, rhs._words.count),
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
                    initializedCount = buffer.count
                }
            )
        )
    }
    
    @inlinable
    public static func ^= (lhs: inout Integer, rhs: Integer) {
        let lhsIsNegative = lhs._isNegative, rhsIsNegative = rhs._isNegative
        guard lhs != 0 else {
            lhs = rhs
            return
        }
        guard rhs != 0 else {
            return
        }
        if lhs._words.count < rhs._words.count {
            lhs._words.reserveCapacity(rhs._words.count)
        }
        for (index, rhWord) in rhs._words.prefix(lhs._words.count)._enumeratedWithIndices() {
            lhs._words[index] ^= rhWord
        }
        if lhs._words.count > rhs._words.count && rhsIsNegative {
            for index in lhs._words.indices.suffix(from: rhs._words.endIndex) {
                lhs._words[index] = ~lhs._words[index]
            }
        }
        if lhs._words.count < rhs._words.count {
            if lhsIsNegative {
                for rhWord in rhs._words.suffix(from: lhs._words.endIndex) {
                    lhs._words.append(~rhWord)
                }
            } else {
                lhs._words.append(contentsOf: rhs._words.suffix(from: lhs._words.endIndex))
            }
        }
        lhs._normalize()
    }
    
    @inlinable
    public static func >> <RHS: BinaryInteger>(lhs: Integer, rhs: RHS) -> Integer {
        guard rhs >= 0 else { return lhs << rhs.magnitude }
        guard rhs != 0 else { return lhs }
        let (quotient, remainder) = rhs.quotientAndRemainder(dividingBy: RHS(UInt.bitWidth))
        guard quotient < lhs._words.count else { return lhs._isNegative ? -1 : 0 }
        let wordwiseShift = Int(quotient)
        let bitwiseShift = Int(remainder)
        let wordCount = lhs._words.count - wordwiseShift
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount,
                initializingWith: { buffer, initializedCount in
                    if bitwiseShift != 0 {
                        let inverseBitwiseShift = UInt.bitWidth - bitwiseShift
                        for index in buffer.indices.dropLast() {
                            let lowWord = lhs._words[index + wordwiseShift], highWord = lhs._words[index + wordwiseShift + 1]
                            buffer.initializeElement(at: index, to: lowWord >> bitwiseShift | highWord << inverseBitwiseShift)
                        }
                        buffer.initializeElement(
                            at: buffer.indices.last.unsafelyUnwrapped,
                            to: lhs._words.last.unsafelyUnwrapped >> bitwiseShift | lhs._signExtendingWord << inverseBitwiseShift
                        )
                    } else {
                        buffer._initializeElements(startingAt: 0, toContentsOf: lhs._words.suffix(from: wordwiseShift))
                    }
                }
            )
        )
    }
    
    @inlinable
    public static func >>= <RHS: BinaryInteger>(lhs: inout Integer, rhs: RHS) {
        lhs = lhs >> rhs
    }
    
    @inlinable
    public static func << <RHS: BinaryInteger>(lhs: Integer, rhs: RHS) -> Integer {
        guard rhs >= 0 else { return lhs >> rhs.magnitude }
        guard rhs != 0 else { return lhs }
        let (quotient, remainder) = rhs.quotientAndRemainder(dividingBy: RHS(UInt.bitWidth))
        guard let wordwiseShift = Int(exactly: quotient) else { preconditionFailure() }
        let bitwiseShift = Int(remainder)
        var wordCount = lhs._words.count + wordwiseShift
        if bitwiseShift != 0 {
            wordCount += 1
        }
        return Integer(
            _words: Array(
                unsafeUninitializedCapacity: wordCount,
                initializingWith: { buffer, initializedCount in
                    if wordwiseShift != 0 {
                        buffer._initializeElements(startingAt: 0, repeating: UInt.min, count: wordwiseShift)
                    }
                    if bitwiseShift != 0 {
                        let inverseBitwiseShift = UInt.bitWidth - bitwiseShift
                        buffer.initializeElement(at: wordwiseShift, to: lhs._words.first.unsafelyUnwrapped << bitwiseShift)
                        for index in buffer.indices.suffix(from: wordwiseShift).dropFirst().dropLast() {
                            let lowWord = lhs._words[index - wordwiseShift - 1], highWord = lhs._words[index - wordwiseShift]
                            buffer.initializeElement(at: index, to: lowWord >> bitwiseShift | highWord << inverseBitwiseShift)
                        }
                        buffer.initializeElement(
                            at: buffer.indices.last.unsafelyUnwrapped,
                            to: lhs._words.last.unsafelyUnwrapped >> inverseBitwiseShift | lhs._signExtendingWord << bitwiseShift
                        )
                    } else {
                        buffer._initializeElements(startingAt: wordwiseShift, toContentsOf: lhs._words)
                    }
                }
            )
        )
    }
    
    @inlinable
    public static func <<= <RHS: BinaryInteger>(lhs: inout Integer, rhs: RHS) {
        lhs = lhs << rhs
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
    public func signum() -> Integer { _isNegative ? -1 : _isZero ? 0 : 1 }
}

extension BinaryFloatingPoint {
    
    @inlinable
    internal func _convertExactlyToInteger() -> Integer? {
        guard isFinite else { return nil }
        guard !isZero else { return 0 }
        guard significandWidth <= exponent else { return nil }
        let significandExponent = exponent - Exponent(significandWidth &+ significandBitPattern.trailingZeroBitCount)
        var integer = 1 << exponent | Integer(significandBitPattern) << significandExponent
        if isLess(than: 0) {
            integer.negate()
        }
        return integer
    }
    
    @inlinable
    internal func _convertToInteger() -> Integer {
        precondition(isFinite)
        guard !isZero else { return 0 }
        let significandExponent = exponent - Exponent(significandWidth &+ significandBitPattern.trailingZeroBitCount)
        var integer = 1 << exponent | Integer(significandBitPattern) << significandExponent
        if isLess(than: 0) {
            integer.negate()
        }
        return integer
    }
}

extension Integer {
    
    @inlinable
    internal func _multipliedUnsigned(by other: Integer) -> Integer {
        let wordCount = _words.count + other._words.count
        var integer = 0 as Integer
        for (index, word) in _words._enumeratedWithIndices() {
            guard word != UInt.min else { continue }
            integer += Integer(
                _words: Array(
                    unsafeUninitializedCapacity: wordCount,
                    initializingWith: { buffer, initializedCount in
                        buffer._initializeElements(startingAt: 0, repeating: UInt.min, count: index)
                        for (otherIndex, otherWord) in other._words._enumeratedWithIndices() {
                            let (high, low) = word.multipliedFullWidth(by: otherWord)
                            fatalError()
                        }
                    }
                )
            )
        }
        return integer
    }
}

extension Integer: SignedInteger {}

extension Integer: Equatable {
    
    @inlinable
    public static func == (lhs: Integer, rhs: Integer) -> Bool { lhs._words == rhs._words }
}

extension Integer: Comparable {
    
    @inlinable
    public static func < (lhs: Integer, rhs: Integer) -> Bool { lhs._compare(to: rhs) == .lessThan }
    
    @inlinable
    public static func <= (lhs: Integer, rhs: Integer) -> Bool { lhs._compare(to: rhs) != .greaterThan }
    
    @inlinable
    public static func >= (lhs: Integer, rhs: Integer) -> Bool { lhs._compare(to: rhs) != .lessThan }
    
    @inlinable
    public static func > (lhs: Integer, rhs: Integer) -> Bool { lhs._compare(to: rhs) == .greaterThan }
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
        case (false, false): return _compareUnsigned(to: other)
        case (false, true): return .greaterThan
        case (true, false): return .lessThan
        case (true, true):
            switch _compareUnsigned(to: other) {
            case .lessThan: return .greaterThan
            case .greaterThan: return .lessThan
            case .equalTo: return .equalTo
            }
        }
    }
    
    @inlinable
    internal func _compareUnsigned(to other: Integer) -> _ComparisonResult {
        guard _words.count == other._words.count else { return _words.count < other._words.count ? .lessThan : .greaterThan }
        for (word, otherWord) in zip(_words.reversed(), other._words.reversed()) {
            guard word == otherWord else { return word < otherWord ? .lessThan : .greaterThan }
        }
        return .equalTo
    }
}

extension Integer: Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_words)
    }
}

extension Integer: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        var codeUnits = [] as [UInt8]
        var magnitude = magnitude
        repeat {
            let (quotient, remainder) = magnitude.quotientAndRemainder(dividingBy: 10)
            codeUnits.append(UInt8(ascii: "0") &+ UInt8(remainder))
            magnitude = quotient
        } while magnitude != 0
        if _isNegative {
            codeUnits.append(UInt8(ascii: "-"))
        }
        codeUnits.reverse()
        return String(
            unsafeUninitializedCapacity: codeUnits.count,
            initializingUTF8With: { buffer in buffer.initialize(fromContentsOf: codeUnits) }
        )
    }
}

extension Integer: LosslessStringConvertible {
    
    @inlinable
    public init?(_ description: String) {
        var description = description
        let integer = description.withUTF8 { codeUnits in _parseInteger(from: codeUnits) }
        guard let integer else { return nil }
        self = integer
    }
}

@inlinable
internal func _parseInteger(from codeUnits: UnsafeBufferPointer<UInt8>) -> Integer? {
    guard !codeUnits.isEmpty else { return nil }
    switch codeUnits[0] {
    case UInt8(ascii: "-"): return _parseIntegerDigits(from: codeUnits.extracting(1...), isNegative: true)
    case UInt8(ascii: "+"): return _parseIntegerDigits(from: codeUnits.extracting(1...), isNegative: false)
    default: return _parseIntegerDigits(from: codeUnits)
    }
}

@inlinable
internal func _parseIntegerDigits(from codeUnits: UnsafeBufferPointer<UInt8>, isNegative: Bool = false) -> Integer? {
    guard !codeUnits.isEmpty else { return nil }
    var integer = 0 as Integer
    for codeUnit in codeUnits {
        guard UInt8(ascii: "0")...UInt8(ascii: "9") ~= codeUnit else { return nil }
        integer *= 10
        integer += Integer(codeUnit &- UInt8(ascii: "0"))
    }
    if isNegative {
        integer.negate()
    }
    return integer
}

extension Integer: Encodable {
    
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(_words)
    }
}

extension Integer: Decodable {
    
    @inlinable
    public init(from decoder: any Decoder) throws {
        let words = try decoder.singleValueContainer().decode([UInt].self)
        guard !words.isEmpty else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot initialize Integer from an empty array of words."
                )
            )
        }
        self.init(_words: words)
    }
}

extension Integer: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = StaticBigInt
    
    @inlinable
    public init(integerLiteral value: StaticBigInt) {
        self.init(
            _words: Array(
                unsafeUninitializedCapacity: value.bitWidth._dividedRoundingUp(by: UInt.bitWidth),
                initializingWith: { buffer, initializedCount in
                    for index in buffer.indices {
                        buffer.initializeElement(at: index, to: value[index])
                    }
                    initializedCount = buffer.count
                }
            )
        )
    }
}

extension Integer: CustomReflectable {
    
    @inlinable
    public var customMirror: Mirror { Mirror(self, children: EmptyCollection()) }
}

extension Integer: @unchecked Sendable {}

extension FixedWidthInteger {
    
    @inlinable
    internal func _addingReportingOverflow(_ rhs: Self, carrying: Bool) -> (partialValue: Self, overflow: Bool) {
        guard carrying else { return addingReportingOverflow(rhs) }
        let (partialValue, overflow) = addingReportingOverflow(rhs)
        return overflow ? (partialValue &+ 1, true) : partialValue.addingReportingOverflow(1)
    }
    
    @inlinable
    internal func _subtractingReportingOverflow(_ rhs: Self, borrowing: Bool) -> (partialValue: Self, overflow: Bool) {
        guard borrowing else { return subtractingReportingOverflow(rhs) }
        let (partialValue, overflow) = subtractingReportingOverflow(rhs)
        return overflow ? (partialValue &- 1, true) : partialValue.subtractingReportingOverflow(1)
    }
}

extension Collection {
    
    @inlinable
    internal func _enumeratedWithIndices() -> Zip2Sequence<Indices, Self> { zip(indices, self) }
}

extension UnsafeMutableBufferPointer {
    
    @inlinable
    internal func _initializeElements(startingAt index: Index, toContentsOf source: some Collection<Element>) {
        precondition(startIndex <= index && index + source.count <= endIndex)
        _ = suffix(from: index).initialize(fromContentsOf: source)
    }
    
    @inlinable
    internal func _initializeElements(startingAt index: Index, repeating repeatedValue: Element, count: Int) {
        precondition(startIndex <= index && index + count <= endIndex)
        suffix(from: index).prefix(count).initialize(repeating: repeatedValue)
    }
}

extension BinaryInteger {
    
    @inlinable
    internal func _dividedRoundingUp(by other: Self) -> Self {
        precondition(other != 0)
        let (quotient, remainder) = quotientAndRemainder(dividingBy: other)
        return remainder != 0 && signum() == other.signum() ? quotient + 1 : quotient
    }
}

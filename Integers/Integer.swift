
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
    
    @inlinable
    internal var _isZero: Bool {
        return _words == [0]
    }
}

extension Integer: AdditiveArithmetic {
    
    @inlinable
    public static var zero: Integer {
        return 0
    }
}

extension Integer: Numeric {
    
    @inlinable
    public init?<T: BinaryInteger>(exactly source: T) {
        self.init(source)
    }
    
    public typealias Magnitude = Integer
    
    @inlinable
    public var magnitude: Integer {
        return _isNegative ? -self : self
    }
}

extension Integer: SignedNumeric {
    
    @inlinable
    public prefix static func - (operand: Integer) -> Integer {
        return 0 - operand
    }
    
    @inlinable
    public mutating func negate() {
        var borrow = false
        for index in _words.indices {
            let (partialValue, overflow) = (0 as UInt)._subtractingReportingOverflow(_words[index], borrowing: borrow)
            _words[index] = partialValue
            borrow = overflow
        }
        if borrow {
            _words.reserveCapacity(_words.count + 1)
            _words.append(.max)
        }
        _normalize()
    }
}

extension Integer: Strideable {
    
    public typealias Stride = Integer
    
    @inlinable
    public func distance(to other: Integer) -> Integer {
        return other - self
    }
    
    @inlinable
    public func advanced(by n: Integer) -> Integer {
        return self + n
    }
}

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
            let significandExponent = source.exponent - T.Exponent(source.significandWidth &+ source.significandBitPattern.trailingZeroBitCount)
            var integer = 1 << source.exponent | Integer(source.significandBitPattern) << significandExponent
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
            let significandExponent = source.exponent - T.Exponent(source.significandWidth &+ source.significandBitPattern.trailingZeroBitCount)
            var integer = 1 << source.exponent | Integer(source.significandBitPattern) << significandExponent
            if source < 0 {
                integer.negate()
            }
            self = integer
        }
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ source: T) {
        if T.isSigned || source.words.last.unsafelyUnwrapped.leadingZeroBitCount != 0 {
            self.init(_words: Array(source.words))
        } else {
            self.init(
                _words: Array(
                    unsafeUninitializedCapacity: source.words.count + 1,
                    initializingWith: { buffer, initializedCount in
                        buffer._initializeElements(startingAt: 0, toContentsOf: source.words)
                        buffer.initializeElement(at: source.words.count, to: 0)
                        initializedCount = buffer.count
                    }
                )
            )
        }
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

extension Integer: SignedInteger {}

extension Integer: Equatable {
    
    @inlinable
    public static func == (lhs: Integer, rhs: Integer) -> Bool {
        return lhs._words == rhs._words
    }
}

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
        for (word, otherWord) in zip(_words.reversed(), other._words.reversed()) {
            guard word == otherWord else {
                return word < otherWord ? .lessThan : .greaterThan
            }
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
            initializingUTF8With: { buffer in
                return buffer.initialize(fromContentsOf: codeUnits)
            }
        )
    }
}

extension Integer: LosslessStringConvertible {
    
    @inlinable
    public init?(_ description: String) {
        var description = description
        let integer = description.withUTF8 { codeUnits in
            return _parseInteger(from: codeUnits)
        }
        guard let integer else {
            return nil
        }
        self = integer
    }
}

@inlinable
internal func _parseInteger(from codeUnits: UnsafeBufferPointer<UInt8>) -> Integer? {
    guard !codeUnits.isEmpty else {
        return nil
    }
    switch codeUnits[0] {
    case UInt8(ascii: "-"):
        return _parseIntegerDigits(from: codeUnits.extracting(1...), isNegative: true)
    case UInt8(ascii: "+"):
        return _parseIntegerDigits(from: codeUnits.extracting(1...), isNegative: false)
    default:
        return _parseIntegerDigits(from: codeUnits)
    }
}

@inlinable
internal func _parseIntegerDigits(from codeUnits: UnsafeBufferPointer<UInt8>, isNegative: Bool = false) -> Integer? {
    guard !codeUnits.isEmpty else {
        return nil
    }
    var integer = 0 as Integer
    for codeUnit in codeUnits {
        guard UInt8(ascii: "0")...UInt8(ascii: "9") ~= codeUnit else {
            return nil
        }
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
    public var customMirror: Mirror {
        return Mirror(self, children: EmptyCollection())
    }
}

extension Integer: @unchecked Sendable {}

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

extension BinaryInteger {
    
    @inlinable
    internal func _dividedRoundingUp(by other: Self) -> Self {
        precondition(other != 0)
        let (quotient, remainder) = quotientAndRemainder(dividingBy: other)
        return remainder != 0 && signum() == other.signum() ? quotient + 1 : quotient
    }
}


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
        fatalError()
    }
    
    @inlinable
    public static func - (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func -= (lhs: inout Integer, rhs: Integer) {
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
        fatalError()
    }
    
    @inlinable
    public static func & (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func &= (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
    
    @inlinable
    public static func | (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func |= (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
    
    @inlinable
    public static func ^ (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public static func ^= (lhs: inout Integer, rhs: Integer) {
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
        fatalError()
    }
}

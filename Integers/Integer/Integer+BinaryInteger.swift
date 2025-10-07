
extension Integer: BinaryInteger {
    
    @inlinable
    public static var isSigned: Bool {
        return true
    }
    
    @inlinable
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        fatalError()
    }
    
    @inlinable
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        fatalError()
    }
    
    @inlinable
    public init<T>(_ source: T) where T : BinaryInteger {
        fatalError()
    }
    
    @inlinable
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        fatalError()
    }
    
    @inlinable
    public init<T>(clamping source: T) where T : BinaryInteger {
        fatalError()
    }
    
    public typealias Words = [UInt]
    
    @inlinable
    public var words: [UInt] {
        fatalError()
    }
    
    @inlinable
    public var bitWidth: Int {
        fatalError()
    }
    
    @inlinable
    public var trailingZeroBitCount: Int {
        fatalError()
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

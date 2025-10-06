
extension Integer: Numeric {
    
    @inlinable
    public init?<T: BinaryInteger>(exactly source: T) {
        fatalError()
    }
    
    public typealias Magnitude = Integer
    
    @inlinable
    public var magnitude: Integer {
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
}


extension Integer: AdditiveArithmetic {
    
    @inlinable
    public static var zero: Integer {
        return 0
    }
    
    @inlinable
    public static func - (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    public static func += (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
    
    @inlinable
    public static func + (lhs: Integer, rhs: Integer) -> Integer {
        fatalError()
    }
    
    public static func -= (lhs: inout Integer, rhs: Integer) {
        fatalError()
    }
}

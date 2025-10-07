
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


extension Integer: Strideable {
    
    public typealias Stride = Integer
    
    @inlinable
    public func distance(to other: Integer) -> Integer {
        fatalError()
    }
    
    @inlinable
    public func advanced(by n: Integer) -> Integer {
        fatalError()
    }
}

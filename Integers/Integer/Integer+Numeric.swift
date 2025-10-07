
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

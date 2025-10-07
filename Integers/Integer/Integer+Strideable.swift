
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
    
    @inlinable
    public static func _step(
      after current: (index: Int?, value: Integer),
      from start: Integer, by distance: Integer
    ) -> (index: Int?, value: Integer) {
        fatalError()
    }
}

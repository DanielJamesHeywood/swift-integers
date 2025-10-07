
extension Integer: Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        fatalError()
    }
    
    @inlinable
    public func _rawHashValue(seed: Int) -> Int {
        fatalError()
    }
}

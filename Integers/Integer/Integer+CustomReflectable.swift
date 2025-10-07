
extension Integer: CustomReflectable {
    
    @inlinable
    public var customMirror: Mirror {
        return Mirror(self, children: EmptyCollection())
    }
}

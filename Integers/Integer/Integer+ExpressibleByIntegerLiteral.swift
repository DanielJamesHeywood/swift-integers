
extension Integer: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = StaticBigInt
    
    @inlinable
    public init(integerLiteral value: StaticBigInt) {
        self.init(
            _words = Array(
                unsafeUninitializedCapacity: value.bitWidth._dividedRoundingUp(by: UInt.bitWidth),
                initializingWith: { buffer, initializedCount in
                    for index in buffer.indices {
                        buffer.initializeElement(at: index, to: value[index])
                    }
                    initializedCount = buffer.count
                }
            )
        )
    }
}

extension BinaryInteger {
    
    @inlinable
    internal func _dividedRoundingUp(by other: Self) -> Self {
        precondition(other != 0)
        let (quotient, remainder) = quotientAndRemainder(dividingBy: other)
        return remainder != 0 && signum() == other.signum() ? quotient + 1 : quotient
    }
}

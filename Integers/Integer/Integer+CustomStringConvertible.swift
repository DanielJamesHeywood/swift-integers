
extension Integer: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        var value = magnitude
        var result = [] as [UInt8]
        repeat {
            let (quotient, remainder) = value.quotientAndRemainder(dividingBy: 10)
            result.append(UInt8(("0" as Unicode.Scalar).value) &+ UInt8(remainder))
            value = quotient
        } while value != 0
        if _isNegative {
            result.append(UInt8(("-" as Unicode.Scalar).value))
        }
        result.reverse()
        return String(
            unsafeUninitializedCapacity: result.count,
            initializingUTF8With: { buffer in
                return buffer.initialize(fromContentsOf: result)
            }
        )
    }
}

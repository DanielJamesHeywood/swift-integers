
extension Integer: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        var result = [] as [UInt8]
        var value = magnitude
        repeat {
            let (quotient, remainder) = value.quotientAndRemainder(dividingBy: 10)
            result.append(UInt8(ascii: "0") &+ UInt8(remainder))
            value = quotient
        } while value != 0
        if _isNegative {
            result.append(UInt8(ascii: "-"))
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

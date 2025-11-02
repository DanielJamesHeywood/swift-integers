
extension Integer: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        var codeUnits = [] as [UInt8]
        var value = magnitude
        repeat {
            let (quotient, remainder) = value.quotientAndRemainder(dividingBy: 10)
            codeUnits.append(UInt8(ascii: "0") &+ UInt8(remainder))
            value = quotient
        } while value != 0
        if _isNegative {
            codeUnits.append(UInt8(ascii: "-"))
        }
        codeUnits.reverse()
        return String(
            unsafeUninitializedCapacity: codeUnits.count,
            initializingUTF8With: { buffer in
                return buffer.initialize(fromContentsOf: codeUnits)
            }
        )
    }
}

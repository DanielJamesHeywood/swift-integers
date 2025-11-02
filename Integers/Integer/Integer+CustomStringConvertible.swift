
extension Integer: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        var codeUnits = [] as [UInt8]
        var magnitude = magnitude
        repeat {
            let (quotient, remainder) = magnitude.quotientAndRemainder(dividingBy: 10)
            codeUnits.append(UInt8(ascii: "0") &+ UInt8(remainder))
            magnitude = quotient
        } while magnitude != 0
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

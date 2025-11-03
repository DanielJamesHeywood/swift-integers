
extension Integer: LosslessStringConvertible {
    
    @inlinable
    public init?(_ description: String) {
        var description = description
        let integer = description.withUTF8 { codeUnits in
            return _parseInteger(from: codeUnits)
        }
        guard let integer else {
            return nil
        }
        self = integer
    }
}

@inlinable
internal func _parseInteger(from codeUnits: UnsafeBufferPointer<UInt8>) -> Integer? {
    guard !codeUnits.isEmpty else {
        return nil
    }
    switch codeUnits[0] {
    case UInt8(ascii: "-"):
        return _parseIntegerDigits(from: codeUnits.extracting(1...), isNegative: true)
    case UInt8(ascii: "+"):
        return _parseIntegerDigits(from: codeUnits.extracting(1...), isNegative: false)
    default:
        return _parseIntegerDigits(from: codeUnits)
    }
}

@inlinable
internal func _parseIntegerDigits(from codeUnits: UnsafeBufferPointer<UInt8>, isNegative: Bool = false) -> Integer? {
    guard !codeUnits.isEmpty else {
        return nil
    }
    var integer = 0 as Integer
    for codeUnit in codeUnits {
        guard UInt8(ascii: "0")...UInt8(ascii: "9") ~= codeUnit else {
            return nil
        }
        integer *= 10
        integer += Integer(codeUnit &- UInt8(ascii: "0"))
    }
    if isNegative {
        integer.negate()
    }
    return integer
}

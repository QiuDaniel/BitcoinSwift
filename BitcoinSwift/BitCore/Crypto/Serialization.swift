//
//  Serialization.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/23.
//
// copy from https://github.com/Sajjon/EllipticCurveKit/blob/main/Sources/EllipticCurveKit/Cryptography/HMAC_DRBG/DataConvertible.swift

import Foundation

public protocol NumberConvertible {
    var number: BigNumber { get }
}

func * (lhs: NumberConvertible, rhs: NumberConvertible) -> BigNumber {
    return lhs.number * rhs.number
}

func * (lhs: NumberConvertible, rhs: BigNumber) -> BigNumber {
    return lhs.number * rhs
}

func * (lhs: BigNumber, rhs: NumberConvertible) -> BigNumber {
    return lhs * rhs.number
}

func + (lhs: NumberConvertible, rhs: NumberConvertible) -> BigNumber {
    return lhs.number + rhs.number
}

func + (lhs: NumberConvertible, rhs: BigNumber) -> BigNumber {
    return lhs.number + rhs
}

func + (lhs: BigNumber, rhs: NumberConvertible) -> BigNumber {
    return lhs + rhs.number
}

public protocol BinaryConvertible: NumberConvertible {
    var data: Data { get }
    var hex: String { get }
}

extension BigNumber {
    init(_ value: BinaryConvertible) {
        self.init(data: value.data)
    }
}

extension NumberConvertible where Self: BinaryConvertible {
    public var number: BigNumber {
        return data.toNumber()
    }
}

public extension BinaryConvertible {
    var byteCount: Int {
        return data.count
    }
    
    var bytes: [UInt8] {
        return data.bytes
    }
    
    var hex: String {
        return data.toHexString()
    }
}

func +(data: BinaryConvertible, byte: UInt8) -> Data {
    return data.data + Data([byte])
}

func +(lhs: Data, rhs: BinaryConvertible) -> Data {
    return Data(lhs.bytes + rhs.data.bytes)
}

func +(lhs: BinaryConvertible, rhs: BinaryConvertible) -> Data {
    var bytes: [UInt8] = lhs.bytes
    bytes.append(contentsOf: rhs.bytes)
    return Data(bytes)
}

func +(lhs: BinaryConvertible, rhs: BinaryConvertible?) -> Data {
    guard let rhs = rhs else { return lhs.data }
    return lhs + rhs
}

func +(data: Data, byte: UInt8) -> Data {
    return data + Data([byte])
}

func +(lhs: Data, rhs: Data?) -> Data {
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}


extension Data: ExpressibleByArrayLiteral {
    public init(arrayLiteral bytes: UInt8...) {
        self.init(bytes)
    }
}

extension Array: BinaryConvertible where Element == UInt8 {
    public var data: Data {
        return Data(self)
    }
    
    public init(data: Data) {
        self.init(data.bytes)
    }
}

extension Array: NumberConvertible where Element == UInt8 {
    public var number: BigNumber {
        return data.toNumber()
    }
}

extension Data: BinaryConvertible {
    public var data: Data {
        return self
    }
    
    public init(data: Data) {
        self = data
    }
}

extension UInt8: BinaryConvertible {
    public var data: Data {
        return Data([self])
    }
    
    public init(data: Data) {
        self = data.bytes.first ?? 0x00
    }
}

public extension BinaryInteger {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension Int8: BinaryConvertible {}

extension UInt16: BinaryConvertible {}
extension Int16: BinaryConvertible {}

extension UInt32: BinaryConvertible {}
extension Int32: BinaryConvertible {}

extension UInt64: BinaryConvertible {}
extension Int64: BinaryConvertible {}


extension Data {
    
    // https://stackoverflow.com/questions/60857760/warning-initialization-of-unsafebufferpointert-results-in-a-dangling-buffer
    init<T>(value: T) {
        self = withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) -> Data in
            return Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }

    mutating func append<T>(value: T) {
        withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) in
            append(UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
    
    func to<T>(_ type: T.Type) -> T {
        var data = Data(count: MemoryLayout<T>.size)
        // Doing this for aligning memory layout
        _ = data.withUnsafeMutableBytes { self.copyBytes(to: $0) }
        return data.withUnsafeBytes { $0.load(as: T.self) }
    }
    
    func to(_ type: String.Type) -> String {
        return String(bytes: self, encoding: .default)!.replacingOccurrences(of: "\0", with: "")
    }
    
    func to(_ type: VarInt.Type) -> VarInt {
        let value: UInt64
        let length = self[0..<1].to(UInt8.self)
        switch length {
        case 0...252:
            value = UInt64(length)
        case 0xfd:
            value = UInt64(self[1...2].to(UInt16.self))
        case 0xfe:
            value = UInt64(self[1...4].to(UInt32.self))
        case 0xff:
            value = self[1...8].to(UInt64.self)
        default:
            fatalError("This switch statement should be exhaustive without default clause")
        }
        return VarInt(value)
    }
}

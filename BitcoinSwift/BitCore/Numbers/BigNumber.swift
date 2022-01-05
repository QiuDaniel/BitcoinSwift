//
//  BigNumber.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/22.
//

import Foundation
import BigInt

public typealias BigNumber = BigInt

public extension BigNumber {
    
    var isEven: Bool {
        return !magnitude[bitAt: 0]
    }
    
    var byteCount: Int {
        return byteCount(from: magnitude.bitWidth)
    }
    
    init(sign: BigNumber.Sign = .plus, words: [BigNumber.Word]) {
        let magnitude = BigNumber.Magnitude(words: words)
        self.init(sign: sign, magnitude: magnitude)
    }
        
    init(sign: BigNumber.Sign = .plus, _ magnitude: BigNumber.Magnitude) {
        self.init(sign: sign, magnitude: magnitude)
    }
    
    init(sign: BigNumber.Sign = .plus, data: Data) {
        self.init(sign: sign, BigNumber.Magnitude(data))
    }
    
    init?(hex: String) {
        var hexString = hex
        if hexString.starts(with: "0x") {
            hexString = String(hexString.dropFirst(2))
        }
        self.init(hexString, radix: 16)
    }
    
    init?(decimal: String) {
        self.init(decimal, radix: 10)
    }
    
    func hexString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 16)
    }
    
    func hexStringLength64(uppercased: Bool = true) -> String {
        var hex = hexString(uppercased: uppercased)
        while hex.count < 64 {
            hex = "0\(hex)"
        }
        return hex
    }
    
    func decimalString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 10)
    }
    
    func toString(uppercased: Bool = true, radix: Int) -> String {
        let stringRepresentation = String(self, radix: radix)
        guard uppercased else { return stringRepresentation }
        return stringRepresentation.uppercased()
    }
    
    func bit256Data() -> Data {
        return Data(hex: hexStringLength64())
    }
    
    func trimmedData() -> Data {
        return magnitude.serialize()
    }
    
    func byteCount(from bitCount: Int) -> Int {
        return Int(floor(Double(bitCount + 7)) / Double(8))
    }
    
}

extension Data {
    func toNumber() -> BigNumber {
        return BigNumber(data: self)
    }
}

extension BigUInt {
    init?(hex: String) {
        var hexString = hex
        if hexString.starts(with: "0x") {
            hexString = String(hexString.dropFirst(2))
        }
        self.init(hexString, radix: 16)
    }
    
    func trimmedData() -> Data {
        return magnitude.serialize()
    }
}

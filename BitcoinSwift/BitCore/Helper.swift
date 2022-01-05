//
//  Helper.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import Foundation

func bytes2bitField(_ bytes: [UInt8]) -> [UInt] {
    var flagBits = [UInt]()
    for byte in bytes {
        var tmpByte = byte
        for _ in 0..<8 {
            flagBits.append(UInt(tmpByte) & 1)
            tmpByte >>= 1
        }
    }
    return flagBits
}

func bitField2Bytes(_ bitField: [UInt]) -> [UInt8]? {
    if bitField.count % 8 != 0 {
        return nil
    }
    var bytes = [UInt8](repeating: 0, count: bitField.count / 8)
    for (i, bit) in bitField.enumerated() {
        let (byteIndex, bitIndex) = i.quotientAndRemainder(dividingBy: 8)
        if bit == 1 {
            bytes[byteIndex] |= 1 << bitIndex
        }
    }
    return bytes
}

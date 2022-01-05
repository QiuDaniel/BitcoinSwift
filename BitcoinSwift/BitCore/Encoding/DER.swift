//
//  DER.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/27.
//

import Foundation

public struct DER {
    static func encode(r: BigNumber, s: BigNumber) -> String {
        let encodeR = encode(r)
        let encodeS = encode(s)
        let encodeStr = encodeR + encodeS
        let byteCount = encodeStr.count / 2
        return DERCode.PREFIX.hex + byteCount.numberHexString + encodeStr
    }
    
    static func decode(data: Data) -> (r: BigNumber, s: BigNumber)? {
        guard data.count > 8, data[0] == DERCode.PREFIX.rawValue, data[1] == data.count - 2, data[2] == DERCode.FLAG.rawValue else {
            return nil
        }
        let rByteCount = Int(data[3])
        let rIndex = 4
        let rData = data[rIndex..<(rIndex + rByteCount)].suffix(32)
        guard rData.count == 32 else {
            return nil
        }
        let r = BigNumber([0] + rData)
        
        guard data[rByteCount + 4] == DERCode.FLAG.rawValue else {
            return nil
        }
        let sByteCount = Int(data[rByteCount + 5])
        let sIndex = rByteCount + 6
        let sData = data[sIndex..<(sIndex + sByteCount)].suffix(32)
        
        guard sData.count == 32 else {
            return nil
        }
        let s = BigNumber([0] + sData)
        
        return (r, s)
    }
}

private extension DER {
    
    static func encode(_ value: BigNumber) -> String {
        let valueBytes = value.trimmedData().bytes
        var bytes: [UInt8]
        if valueBytes[0] >= 0x80 {
            bytes = [0x0] + valueBytes
        } else {
            bytes = valueBytes
        }
        return DERCode.FLAG.hex + bytes.count.numberHexString + bytes.toHexString()
    }
    
}

private enum DERCode: UInt8 {
    case PREFIX = 0x30
    case FLAG = 0x02
}

extension DERCode {
    var hex: String {
        return Int(rawValue).numberHexString
    }
}

private extension Int {
    var numberHexString: String {
        return String(format: "%02x", self)
    }
}

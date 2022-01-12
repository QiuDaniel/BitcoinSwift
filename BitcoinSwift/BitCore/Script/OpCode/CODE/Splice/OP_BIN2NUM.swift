//
//  OP_BIN2NUM.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// bitcoin cash
public struct OpBin2Num: OpCodeType {
    public var value: UInt8 { return 0x81 }
    public var name: String { return "OP_BIN2NUM" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let data = context.data(at: -1)
        let minEncodeData = minimallyEncode(data)
        try context.push(minEncodeData)
        
    }
    
    private func minimallyEncode(_ value: Data) -> Data {
        guard value.count > 1 else {
            return .empty
        }
        var data = value
        let last: UInt8 = data.last!
        if last & 0x7f > 0 {
            return data
        }
        guard data[data.count - 2] & 0x80 == 0 else {
            return data
        }
        while data.count > 1 {
            let i = data.count - 1
            if data[i - 1] != 0 {
                if data[i - 1] & 0x80 != 0 {
                    data[i] = last
                } else {
                    data[i - 1] |= last
                    data.removeLast()
                }
                return data
            } else {
                data.remove(at: i - 1)
            }
        }
        return .empty
    }
}

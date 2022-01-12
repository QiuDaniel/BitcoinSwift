//
//  OP_NUM2BIN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// bitcoin cash
public struct OpNum2Bin: OpCodeType {
    public var value: UInt8 { return 0x80 }
    public var name: String { return "OP_NUM2BIN" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let size = try context.number(at: -1)
        guard size <= BTC_MAX_SCRIPT_ELEMENT_SIZE else {
            throw OpCodeExcutionError.error("Push value size limit exceeded.")
        }
        var data = context.data(at: -1)
        guard data.count <= Int(size) else {
            throw OpCodeExcutionError.error("The requested encoding is impossible to satisfy")
        }
        if data.count < Int(size) {
            var signBit: UInt8 = 0x00
            if data.count > 0 {
                signBit = data.last! & 0x80
                data[data.count - 1] &= 0x7f
            }
            while data.count < size - 1 {
                data.append(0x00)
            }
            data.append(signBit)
        }
        try context.push(data)
    }
}

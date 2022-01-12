//
//  OP_XOR.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpXor: OpCodeType {
    public var value: UInt8 { return 0x86 }
    public var name: String { return "OP_XOR" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x2 = context.remove(at: -1)
        let x1 = context.remove(at: -1)
        
        guard x1.count == x2.count else {
            throw OpCodeExcutionError.error("Invalid OP_XOR size")
        }
        let count = x1.count
        var output = Data(count: count)
        for index in 0..<count {
            output[index] = x1[index] ^ x2[index]
        }
        try context.push(output)
    }
}

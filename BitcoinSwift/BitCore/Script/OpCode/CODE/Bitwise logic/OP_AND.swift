//
//  OP_AND.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpAnd: OpCodeType {
    public var value: UInt8 { return 0x84 }
    public var name: String { return "OP_AND" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        
        try context.assertStackHeightGreaterThanOrEqual(2)
        
        let x2 = context.remove(at: -1)
        let x1 = context.remove(at: -1)
        
        guard x1.count == x2.count else {
            throw OpCodeExcutionError.error("Invalid OP_AND size")
        }
        
        let count = x1.count
        var output = Data(count: count)
        for i in 0..<count {
            output[i] = x1[i] & x2[i]
        }
        try context.push(output)
    }
}

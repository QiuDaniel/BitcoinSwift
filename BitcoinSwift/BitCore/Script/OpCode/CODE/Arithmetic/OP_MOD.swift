//
//  OP_MOD.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpMod: OpCodeType {
    public var value: UInt8 { return 0x97 }
    public var name: String { return "OP_MOD" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        
        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        
        guard x1 != 0 else {
            throw OpCodeExcutionError.error("Modulo by zero error")
        }
        
        context.push(x2 % x1)
    }
}

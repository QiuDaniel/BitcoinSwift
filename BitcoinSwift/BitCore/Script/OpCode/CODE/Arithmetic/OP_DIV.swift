//
//  OP_DIV.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpDiv: OpCodeType {
    public var value: UInt8 { return 0x96 }
    public var name: String { return "OP_DIV" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x2 = try context.number(at: -1)
        let x1 = try context.number(at: -1)
        
        guard x2 != 0 else {
            throw OpCodeExcutionError.error("Division by zero erro")
        }
        context.push(x1 / x2)
    }
}

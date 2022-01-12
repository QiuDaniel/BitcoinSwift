//
//  OP_1ADD.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op1Add: OpCodeType {
    public var value: UInt8 {
        return 0x8b
    }
    
    public var name: String {
        return "OP_1ADD"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let input = try context.number(at: -1)
        context.push(input + Int32(1))
    }
}

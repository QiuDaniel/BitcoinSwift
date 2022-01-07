//
//  OP_1SUB.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op1Sub: OpCodeType {
    public var value: UInt8 {
        return 0x8c
    }
    
    public var name: String {
        return "OP_1SUB"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let input = try context.number(at: -1)
        context.push(input - 1)
    }
}

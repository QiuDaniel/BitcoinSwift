//
//  OP_SUB.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSub: OpCodeType {
    public var value: UInt8 { return 0x94 }
    public var name: String { return "OP_SUB" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)

        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        context.push(x2 - x1)
    }
}

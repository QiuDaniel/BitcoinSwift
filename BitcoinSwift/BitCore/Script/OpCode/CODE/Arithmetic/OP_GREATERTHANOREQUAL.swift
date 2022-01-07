//
//  OP_GREATERTHANOREQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpGreaterThanOrEqual: OpCodeType {
    public var value: UInt8 { return 0xa2 }
    public var name: String { return "OP_GREATERTHANOREQUAL" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        context.push(x2 >= x1)
    }
}

//
//  OP_LESSTHANOREQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpLessThanOrEqual: OpCodeType {
    public var value: UInt8 { return 0xa1 }
    public var name: String { return "OP_LESSTHANOREQUAL" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        context.push(x2 <= x1)
    }
}

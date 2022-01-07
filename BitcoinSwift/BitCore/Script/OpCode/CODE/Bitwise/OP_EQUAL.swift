//
//  OP_EQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpEqual: OpCodeType {
    public var value: UInt8 { return 0x87 }
    public var name: String { return "OP_EQUAL" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = context.remove(at: -1)
        let x2 = context.remove(at: -1)
        context.push(x1 == x2)
    }
}

//
//  OP_IF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpIf: OpCodeType {
    public var value: UInt8 { return 0x63 }
    public var name: String { return "OP_IF" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        var value: Bool = false
        if context.shouldExcute {
            try context.assertStackHeightGreaterThanOrEqual(1)
            value = context.bool(at: -1)
        }
        context.conditionStack.append(value)
    }
}

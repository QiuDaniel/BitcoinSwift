//
//  OP_NOTIF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNotIf: OpCodeType {
    public var value: UInt8 { return 0x64 }
    public var name: String { return "OP_NOTIF" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        var value: Bool = false
        if context.shouldExcute {
            try context.assertStackHeightGreaterThanOrEqual(1)
            value = context.bool(at: -1)
        }
        context.conditionStack.append(!value)
    }
}

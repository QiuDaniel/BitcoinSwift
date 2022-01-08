//
//  OP_FROMALTSTACK.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpFromAltStack: OpCodeType {
    public var value: UInt8 { return 0x6c }
    public var name: String { return "OP_FROMALTSTACK" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertAltStackHeightGreaterThanOrEqual(1)
        let x = context.altStack.removeLast()
        try context.push(x)
    }
}

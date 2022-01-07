//
//  OP_BOOLAND.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpBoolAnd: OpCodeType {
    public var value: UInt8 {
        return 0x9a
    }
    
    public var name: String {
        return "OP_BOOLAND"
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = context.data(at: -1)
        let x2 = context.data(at: -1)
        context.push(x1 != .empty && x2 != .empty)
    }
}

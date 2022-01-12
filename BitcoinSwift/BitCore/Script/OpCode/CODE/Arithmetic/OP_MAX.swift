//
//  OP_MAX.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpMax: OpCodeType {
    public var value: UInt8 { return 0xa4 }
    public var name: String { return "OP_MAX" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        context.push(max(x1, x2))
    }
}

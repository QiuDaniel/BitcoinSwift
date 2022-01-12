//
//  OP_MIN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpMin: OpCodeType {
    public var value: UInt8 { return 0xa3 }
    public var name: String { return "OP_MIN" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        context.push(min(x1, x2))
    }
}

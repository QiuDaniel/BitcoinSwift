//
//  OP_WITHIN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpWithin: OpCodeType {
    public var value: UInt8 { return 0xa5 }
    public var name: String { return "OP_WITHIN" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(3)

        let maximum = try context.number(at: -1)
        let minimum = try context.number(at: -1)
        let x = try context.number(at: -1)
        context.push(minimum <= x && x < maximum)
    }
}

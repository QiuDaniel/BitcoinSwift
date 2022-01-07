//
//  OP_NUMNOTEQUAL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNumNotEqual: OpCodeType {
    public var value: UInt8 { return 0xe }
    public var name: String { return "OP_NUMNOTEQUAL" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = try context.number(at: -1)
        let x2 = try context.number(at: -1)
        context.push(x1 != x2)
    }
}

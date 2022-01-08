//
//  OP_CAT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// bitcoin cash
public struct OpCat: OpCodeType {
    public var value: UInt8 { return 0x7e }
    public var name: String { return "OP_CAT" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = context.data(at: -1)
        let x2 = context.data(at: -1)
        try context.push(x2 + x1)
    }
}

//
//  OP_2DUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Duplicate: OpCodeType {
    public var value: UInt8 { return 0x6e }
    public var name: String { return "OP_2DUP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = context.data(at: -2, pop: false)
        let x2 = context.data(at: -1, pop: false)
        try context.push(x1)
        try context.push(x2)
    }
}

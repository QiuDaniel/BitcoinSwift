//
//  OP_2OVER.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Over: OpCodeType {
    public var value: UInt8 { return 0x70 }
    public var name: String { return "OP_2OVER" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let x1 = context.data(at: -4, pop: false)
        let x2 = context.data(at: -3, pop: false)
        try context.push(x1)
        try context.push(x2)
    }
}

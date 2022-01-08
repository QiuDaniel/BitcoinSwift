//
//  OP_DUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpDuplicate: OpCodeType {
    public var value: UInt8 { return 0x76 }
    public var name: String { return "OP_DUP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let x = context.data(at: -1, pop: false)
        try context.push(x)
    }
}

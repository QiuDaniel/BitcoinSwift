//
//  OP_3DUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op3Duplicate: OpCodeType {
    public var value: UInt8 { return 0x6f }
    public var name: String { return "OP_3DUP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(3)
        let x1 = context.data(at: -3, pop: false)
        let x2 = context.data(at: -2, pop: false)
        let x3 = context.data(at: -1, pop: false)
        
        try context.push(x1)
        try context.push(x2)
        try context.push(x3)
    }
}

//
//  OP_NOT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNot: OpCodeType {
    public var value: UInt8 { return 0x91 }
    public var name: String { return "OP_NOT" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let element = try context.number(at: -1)
        context.push(element == 0)
    }
}

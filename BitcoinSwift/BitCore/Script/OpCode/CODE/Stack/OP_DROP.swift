//
//  OP_DROP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpDrop: OpCodeType {
    public var value: UInt8 { return 0x75 }
    public var name: String { return "OP_DROP" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        context.remove(at: -1)
    }
}

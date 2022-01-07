//
//  OP_INVERT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpInvert: OpCodeType {
    public var value: UInt8 { return 0x83 }
    public var name: String { return "OP_INVERT" }

    public var isEnabled: Bool {
        return false
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)

        let x = context.remove(at: -1)
        let output: Data = Data(value: x.map { ~$0 })
        try context.push(output)
    }
}

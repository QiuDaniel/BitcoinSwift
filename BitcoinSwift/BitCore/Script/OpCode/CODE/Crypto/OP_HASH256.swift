//
//  OP_HASH256.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpHash256: OpCodeType {
    public var value: UInt8 { return 0xaa }
    public var name: String { return "OP_HASH256" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let element = context.remove(at: -1)
        try context.push(Crypto.hash256(element))
    }
}

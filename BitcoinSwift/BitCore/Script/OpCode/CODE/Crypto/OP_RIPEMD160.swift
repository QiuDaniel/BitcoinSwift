//
//  OP_RIPEMD160.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpRipemd160: OpCodeType {
    public var value: UInt8 { return 0xa6 }
    public var name: String { return "OP_RIPEMD160" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let element = context.remove(at: -1)
        try context.push(Crypto.ripemd160(element))
    }
}

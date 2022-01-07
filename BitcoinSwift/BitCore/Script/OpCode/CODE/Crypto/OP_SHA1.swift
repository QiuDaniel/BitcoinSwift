//
//  OP_SHA1.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSha1: OpCodeType {
    public var value: UInt8 { return 0xa7 }
    public var name: String { return "OP_SHA1" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)
        let element = context.remove(at: -1)
        try context.push(Crypto.sha1(element))
    }
}

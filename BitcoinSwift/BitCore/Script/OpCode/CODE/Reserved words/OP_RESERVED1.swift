//
//  OP_RESERVED1.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpReserved1: OpCodeType {
    public var value: UInt8 { return 0x89 }
    public var name: String { return "OP_RESERVED1" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        throw OpCodeExcutionError.error("\(name) should not be executed.")
    }
}

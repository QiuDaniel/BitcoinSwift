//
//  OP_PUBKEYHASH.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpPubkeyHash: OpCodeType {
    public var value: UInt8 { return 0xfd }
    public var name: String { return "OP_PUBKEYHASH" }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        throw OpCodeExcutionError.error("OP_PUBKEYHASH should not be executed.")
    }
}

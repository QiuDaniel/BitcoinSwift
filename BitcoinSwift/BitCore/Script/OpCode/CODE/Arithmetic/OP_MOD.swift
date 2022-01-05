//
//  OP_MOD.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpMod: OpCodeType {
    public var value: UInt8 { return 0x97 }
    public var name: String { return "OP_MOD" }
}

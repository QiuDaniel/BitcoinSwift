//
//  OP_XOR.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpXor: OpCodeType {
    public var value: UInt8 { return 0x86 }
    public var name: String { return "OP_XOR" }
}

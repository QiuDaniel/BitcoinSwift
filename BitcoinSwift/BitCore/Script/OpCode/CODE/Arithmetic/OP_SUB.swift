//
//  OP_SUB.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSub: OpCodeType {
    public var value: UInt8 { return 0x94 }
    public var name: String { return "OP_SUB" }
}

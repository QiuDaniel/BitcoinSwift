//
//  OP_1NEGATE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op1Negate: OpCodeType {
    public var value: UInt8 { return 0x4f }
    public var name: String { return "OP_1NEGATE" }
}

//
//  OP_CHECKSEQUENCEVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckSequenceVerify: OpCodeType {
    public var value: UInt8 { return 0xb2 }
    public var name: String { return "OP_CHECKSEQUENCEVERIFY" }
}

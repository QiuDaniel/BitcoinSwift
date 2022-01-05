//
//  OP_HASH160.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpHash160: OpCodeType {
    public var value: UInt8 { return 0xa9 }
    public var name: String { return "OP_HASH160" }
}

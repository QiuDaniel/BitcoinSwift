//
//  OP_LESSTHAN.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpLessThan: OpCodeType {
    public var value: UInt8 { return 0x9f }
    public var name: String { return "OP_LESSTHAN" }
}

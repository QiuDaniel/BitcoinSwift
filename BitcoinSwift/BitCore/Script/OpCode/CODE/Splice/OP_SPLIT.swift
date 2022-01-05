//
//  OP_SPLIT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSplit: OpCodeType {
    public var value: UInt8 { return 0x7f }
    public var name: String { return "OP_SPLIT" }
}

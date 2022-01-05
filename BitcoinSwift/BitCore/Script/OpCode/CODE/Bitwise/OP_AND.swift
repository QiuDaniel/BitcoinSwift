//
//  OP_AND.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpAnd: OpCodeType {
    public var value: UInt8 { return 0x84 }
    public var name: String { return "OP_AND" }
}

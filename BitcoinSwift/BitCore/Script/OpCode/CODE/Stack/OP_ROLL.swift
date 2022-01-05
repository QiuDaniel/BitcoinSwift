//
//  OP_ROLL.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpRoll: OpCodeType {
    public var value: UInt8 { return 0x7a }
    public var name: String { return "OP_ROLL" }
}

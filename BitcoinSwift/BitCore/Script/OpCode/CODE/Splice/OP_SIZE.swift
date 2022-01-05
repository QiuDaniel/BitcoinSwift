//
//  OP_SIZE.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpSize: OpCodeType {
    public var value: UInt8 { return 0x82 }
    public var name: String { return "OP_SIZE" }
}

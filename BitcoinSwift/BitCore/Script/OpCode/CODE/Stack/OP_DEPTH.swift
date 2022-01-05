//
//  OP_DEPTH.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpDepth: OpCodeType {
    public var value: UInt8 { return 0x74 }
    public var name: String { return "OP_DEPTH" }
}

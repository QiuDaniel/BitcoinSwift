//
//  OP_RESERVED.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpReserved: OpCodeType {
    public var value: UInt8 { return 0x50 }
    public var name: String { return "OP_RESERVED" }
}

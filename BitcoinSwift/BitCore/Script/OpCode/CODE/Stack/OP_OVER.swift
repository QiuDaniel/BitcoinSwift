//
//  OP_OVER.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpOver: OpCodeType {
    public var value: UInt8 { return 0x78 }
    public var name: String { return "OP_OVER" }
}

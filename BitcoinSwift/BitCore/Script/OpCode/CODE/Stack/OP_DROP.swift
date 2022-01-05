//
//  OP_DROP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpDrop: OpCodeType {
    public var value: UInt8 { return 0x75 }
    public var name: String { return "OP_DROP" }
}

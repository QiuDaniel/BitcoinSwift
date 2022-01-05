//
//  OP_ROT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpRot: OpCodeType {
    public var value: UInt8 { return 0x7b }
    public var name: String { return "OP_ROT" }
}

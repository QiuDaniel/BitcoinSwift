//
//  OP_3DUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op3Duplicate: OpCodeType {
    public var value: UInt8 { return 0x6f }
    public var name: String { return "OP_3DUP" }
}

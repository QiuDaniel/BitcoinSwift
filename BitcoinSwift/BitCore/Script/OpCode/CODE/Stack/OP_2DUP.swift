//
//  OP_2DUP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Duplicate: OpCodeType {
    public var value: UInt8 { return 0x6e }
    public var name: String { return "OP_2DUP" }
}

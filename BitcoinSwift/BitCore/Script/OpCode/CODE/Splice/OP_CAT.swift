//
//  OP_CAT.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCat: OpCodeType {
    public var value: UInt8 { return 0x7e }
    public var name: String { return "OP_CAT" }
}

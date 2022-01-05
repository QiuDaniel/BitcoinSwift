//
//  OP_DIV.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpDiv: OpCodeType {
    public var value: UInt8 { return 0x96 }
    public var name: String { return "OP_DIV" }
}

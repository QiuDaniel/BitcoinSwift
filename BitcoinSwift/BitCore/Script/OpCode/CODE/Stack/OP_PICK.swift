//
//  OP_PICK.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpPick: OpCodeType {
    public var value: UInt8 { return 0x79 }
    public var name: String { return "OP_PICK" }
}

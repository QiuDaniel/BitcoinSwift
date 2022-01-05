//
//  OP_2SWAP.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct Op2Swap: OpCodeType {
    public var value: UInt8 { return 0x72 }
    public var name: String { return "OP_2SWAP" }
}

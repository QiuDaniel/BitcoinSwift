//
//  OP_CHECKSIG.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckSig: OpCodeType {
    public var value: UInt8 { return 0xac }
    public var name: String { return "OP_CHECKSIG" }
}

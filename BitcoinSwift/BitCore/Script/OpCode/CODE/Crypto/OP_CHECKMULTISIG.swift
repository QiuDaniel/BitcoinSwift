//
//  OP_CHECKMULTISIG.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckMultiSig: OpCodeType {
    public var value: UInt8 { return 0xae }
    public var name: String { return "OP_CHECKMULTISIG" }
}

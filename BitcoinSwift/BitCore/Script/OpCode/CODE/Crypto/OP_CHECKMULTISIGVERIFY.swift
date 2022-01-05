//
//  OP_CHECKMULTISIGVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckMultiSigVerify: OpCodeType {
    public var value: UInt8 { return 0xaf }
    public var name: String { return "OP_CHECKMULTISIGVERIFY" }
}

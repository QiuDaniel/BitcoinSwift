//
//  OP_PUBKEY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpPubkey: OpCodeType {
    public var value: UInt8 { return 0xfe }
    public var name: String { return "OP_PUBKEY" }
}

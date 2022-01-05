//
//  OP_HASH256.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpHash256: OpCodeType {
    public var value: UInt8 { return 0xaa }
    public var name: String { return "OP_HASH256" }
}

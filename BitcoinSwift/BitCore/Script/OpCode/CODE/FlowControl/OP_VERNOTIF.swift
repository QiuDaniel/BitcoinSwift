//
//  OP_VERNOTIF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpVerNotIf: OpCodeType {
    public var value: UInt8 { return 0x66 }
    public var name: String { return "OP_VERNOTIF" }
}

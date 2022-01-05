//
//  OP_VERIF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpVerIf: OpCodeType {
    public var value: UInt8 { return 0x65 }
    public var name: String { return "OP_VERIF" }
}

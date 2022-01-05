//
//  OP_NOTIF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpNotIf: OpCodeType {
    public var value: UInt8 { return 0x64 }
    public var name: String { return "OP_NOTIF" }
}

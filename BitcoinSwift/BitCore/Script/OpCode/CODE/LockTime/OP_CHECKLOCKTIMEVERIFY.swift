//
//  OP_CHECKLOCKTIMEVERIFY.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpCheckLockTimeVerify: OpCodeType {
    public var value: UInt8 { return 0xb1 }
    public var name: String { return "OP_CHECKLOCKTIMEVERIFY " }
}

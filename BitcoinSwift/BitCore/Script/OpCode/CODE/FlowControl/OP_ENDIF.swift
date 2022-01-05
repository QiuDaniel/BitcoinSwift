//
//  OP_ENDIF.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpEndIf: OpCodeType {
    public var value: UInt8 { return 0x68 }
    public var name: String { return "OP_ENDIF" }
}

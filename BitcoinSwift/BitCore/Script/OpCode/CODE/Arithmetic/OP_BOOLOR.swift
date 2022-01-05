//
//  OP_BOOLOR.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

public struct OpBoolOr: OpCodeType {
    public var value: UInt8 {
        return 0x9b
    }
    
    public var name: String {
        return "OP_BOOLOR"
    }
}

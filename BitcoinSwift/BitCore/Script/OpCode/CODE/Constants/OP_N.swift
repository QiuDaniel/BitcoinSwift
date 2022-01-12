//
//  OP_N.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// The number in the word name (1-16) is pushed onto the stack.
public struct OpN: OpCodeType {
    public var value: UInt8 { return 0x50 + n }
    public var name: String { return "OP_\(n)" }
    
    
    private let n: UInt8
    
    internal init(_ n: UInt8) {
        guard (1...16).contains(n) else {
            fatalError("OP_N can be initialized with N between 1 and 16. \(n) is not valid.")
        }
        self.n = n
    }
    
    public func excuteProcess(_ context: ScriptExcutionContext) throws {
        context.push(Int32(n))
    }
}

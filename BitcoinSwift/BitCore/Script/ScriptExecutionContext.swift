//
//  ScriptExecutionContext.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/4.
//
// copy from BitcoinKit

import Foundation

public final class ScriptExcutionContext {
    
    // TODO: - verificationFlags
//    public var verificationFlags: ScriptVerification?
    
    public internal(set) var stack = [Data]()
    public internal(set) var altStack = [Data]()
    
    public internal(set) var conditionStack = [Data]()
    public internal(set) var opCount: Int = 0
    
    
    
}

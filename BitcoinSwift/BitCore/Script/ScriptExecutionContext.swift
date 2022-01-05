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
    // Holds an array of Bool values to keep track of if/else branches.
    public internal(set) var conditionStack = [Bool]()
    // Keeps number of executed operations to check for limit.
    public internal(set) var opCount: Int = 0
    
    // Transaction, utxo, index for CHECKSIG operations
    public private(set) var transaction: Transaction?
    public private(set) var utxoToVerify: TransactionOutput?
    public private(set) var txinToVerify: TransactionInput?
    public private(set) var inputIndex: UInt32 = 0xffffffff
    
    public var blockTimestamp: UInt32 = UInt32(Date().timeIntervalSince1970)
    
    private let blobFalse: Data = .empty
    private let blobZero: Data = .empty
    private let blobTrue: Data = Data(UInt8(1))
    
    public var verbose: Bool = false
    
    public var shouldExecute: Bool {
        return !conditionStack.contains(false)
    }

    public func shouldVerifyP2SH() -> Bool {
        return blockTimestamp >= BTC_BIP16_TIMESTAMP
    }
    
    public init(_ verbose: Bool = false) {
        self.verbose = verbose
    }
    
    public init?(transaction: Transaction, utxoToVerify: TransactionOutput, inputIndex: UInt32) {
        guard transaction.inputs.count > inputIndex else {
            return nil
        }
        self.transaction = transaction
        self.utxoToVerify = utxoToVerify
        self.txinToVerify = transaction.inputs[Int(inputIndex)]
        self.inputIndex = inputIndex
    }
}

public extension ScriptExcutionContext {
    
    func push(_ bool: Bool) {
        stack.append(bool ? blobTrue : blobFalse)
    }
    
    func push(_ n: Int32) {
        stack.append(BigNumber(n.littleEndian).data)
    }
    
    func push(_ data: Data) throws {
        guard data.count <= BTC_MAX_SCRIPT_ELEMENT_SIZE else {
            throw OpCodeExecutionError.error("PushedData size is too big.")
        }
        stack.append(data)
    }
    
    func resetStack() {
        stack = []
        altStack = []
        conditionStack = []
    }
    
    func swapAt(i: Int, j: Int) {
        stack.swapAt(normalized(i), normalized(j))
    }
    
    func assertStackHeightGreaterThanOrEqual(_ n: Int) throws {
        guard stack.count >= n else {
            throw OpCodeExecutionError.opcodeRequiresItemOnStack(n)
        }
    }

    func assertAltStackHeightGreaterThanOrEqual(_ n: Int) throws {
        guard altStack.count >= n else {
            throw OpCodeExecutionError.error("Operation requires \(n) items on altstack.")
        }
    }

    func incrementOpCount(by i: Int = 1) throws {
        opCount += i
        guard opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            throw OpCodeExecutionError.error("Exceeded the allowed number of operations per script.")
        }
    }
    
}

// MARK: - Private method

private extension ScriptExcutionContext {
    
    func normalized(_ index: Int) -> Int {
        return (index < 0) ? stack.count + index : index
    }
    
}

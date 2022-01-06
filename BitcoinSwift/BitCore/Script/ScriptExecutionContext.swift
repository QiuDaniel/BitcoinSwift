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
    
    public var shouldExcute: Bool {
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
    
    func parseP2SHScript(_ stack: [Data]) throws -> Script {
        var stackForP2SH = stack
        guard let last = stackForP2SH.last, let deserializedScript = Script(last) else {
            throw ScriptError.error("internal inconsistency: stack for P2SH cannot be empty at this point.")
        }
        stackForP2SH.removeLast()
        resetStack()
        self.stack = stackForP2SH
        return deserializedScript
    }
    
    func remove(at i: Int) {
        stack.remove(at: normalized(i))
    }
    
    func data(at i: Int) -> Data {
        return stack[normalized(i)]
    }
    
    func number(at i: Int) throws -> Int32 {
        let data = data(at: i)
        guard data.count <= 4 else {
            throw OpCodeExecutionError.invalidBigNumber
        }
        return data.to(Int32.self)
    }
    
    func bool(at i: Int) -> Bool {
        let data = data(at: i)
        guard !data.isEmpty else {
            return false
        }
        for (index, byte) in data.enumerated() where byte != 0 {
            if index == (data.count - 1) && byte == 0x80 {
                return false
            }
            return true
        }
        return false
    }
}

extension ScriptExcutionContext: CustomStringConvertible {
    public var description: String {
        var desc: String = ""
        for data in stack.reversed() {
            let hex = data.hex
            var contents: String = "0x" + hex

            if hex.count > 20 {
                let first = hex.prefix(5)
                let last = hex.suffix(5)
                contents = "\(first)..\(last) [\(data.count)bytes]"
            }

            if contents == "0x" {
                contents = "NULL [FALSE/0]"
            }

            if contents == "0x01" {
                contents = "0x01 [TRUE/1]"
            }

            for _ in 0...(24 - contents.count) / 2 {
                contents = " \(contents) "
            }
            desc += "| \(contents) |\n"
        }
        var base: String = ""
        (0...14).forEach { _ in
            base = "=\(base)="
        }
        return desc + base + "\n"
    }
}


// MARK: - Private method

private extension ScriptExcutionContext {
    
    func normalized(_ index: Int) -> Int {
        return (index < 0) ? stack.count + index : index
    }
    
}

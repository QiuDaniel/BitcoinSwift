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
    
    public init?(transaction: Transaction, utxoToVerify: TransactionOutput, inputIndex: UInt32, verbose: Bool = false) {
        guard transaction.inputs.count > inputIndex else {
            return nil
        }
        self.transaction = transaction
        self.utxoToVerify = utxoToVerify
        self.txinToVerify = transaction.inputs[Int(inputIndex)]
        self.inputIndex = inputIndex
        self.verbose = verbose
    }
}

public extension ScriptExcutionContext {
    
    func push(_ bool: Bool) {
        stack.append(bool ? blobTrue : blobFalse)
    }
    
    func push(_ n: Int32) {
        stack.append(encode(n))
    }
    
    func push(_ data: Data) throws {
        guard data.count <= BTC_MAX_SCRIPT_ELEMENT_SIZE else {
            throw OpCodeExcutionError.error("Push value size limit exceeded")
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
            throw OpCodeExcutionError.opcodeRequiresItemsOnStack(n)
        }
    }

    func assertAltStackHeightGreaterThanOrEqual(_ n: Int) throws {
        guard altStack.count >= n else {
            throw OpCodeExcutionError.error("Operation requires \(n) items on altstack.")
        }
    }

    func incrementOpCount(by i: Int = 1) throws {
        opCount += i
        guard opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            throw OpCodeExcutionError.error("Exceeded the allowed number of operations per script.")
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
    
    @discardableResult
    func remove(at i: Int) -> Data {
        return stack.remove(at: normalized(i))
    }
    
    func insert(_ newElement: Data, at i: Int) {
        stack.insert(newElement, at: normalized(i))
    }
    
    func data(at i: Int, pop: Bool = true) -> Data {
        if pop {
            return remove(at: i)
        }
        return stack[normalized(i)]
    }
    
    func number(at i: Int, pop: Bool = true) throws -> Int32 {
        let data = data(at: i, pop: pop)
        guard data.count <= 4 else {
            throw OpCodeExcutionError.invalidBigNumber
        }
        return decode(data)
    }
    
    func bool(at i: Int, pop: Bool = true) -> Bool {
        let data = data(at: i, pop: pop)
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
    
    func encode(_ num: Int32) -> Data {
        if num == 0 {
            return .empty
        }
        let isNegative = num < 0
        var value: UInt32 = isNegative ? UInt32(-num) : UInt32(num)
        var result = Data.empty
        repeat {
            result.append(UInt8(value & 0xff))
            value >>= 8
        } while value > 0
        if result.last! & 0x80 > 0 {
            isNegative ? result.append(0x80) : result.append(0x00)
        } else if isNegative {
            var last = result.removeLast()
            last |= 0x80
            result.append(last)
        }
        return result
    }
    
    func decode(_ data: Data) -> Int32 {
        if data == .empty {
            return 0
        }
        let bigEndian = Data(data.reversed()).bytes
        var result: UInt32 = 0
        let isNegative: Bool
        if bigEndian[0] & 0x80 > 0 {
            isNegative = true
            result = UInt32(bigEndian[0] & 0x7f)
        } else {
            isNegative = false
            result = UInt32(bigEndian[0])
        }
        for c in bigEndian[1..<bigEndian.count] {
            result <<= 8
            result += UInt32(c)
        }
        return isNegative ? -Int32(result) : Int32(result)
    }
    
    func encodeNum(_ num: Int32) -> Data {
        let isNegative: Bool = num < 0
        var value: UInt32 = isNegative ? UInt32(-num) : UInt32(num)

        var data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        while data.last == 0 {
            data.removeLast()
        }

        var bytes: [UInt8] = []
        for d in data.reversed() {
            if bytes.isEmpty && d >= 0x80 {
                bytes.append(0)
            }
            bytes.append(d)
        }

        if isNegative {
            let first = bytes.removeFirst()
            bytes.insert(first + 0x80, at: 0)
        }

        let bignum = Data(bytes.reversed())
        return bignum
    }
    
    func decodeNum(_ element: Data) -> Int32 {
        guard !element.isEmpty else {
            return 0
        }
        var data = element
        var bytes = [UInt8]()
        var last = data.removeLast()
        let isNegative: Bool = last >= 0x80
        while !data.isEmpty {
            bytes.append(data.removeFirst())
        }
        if isNegative {
            last -= 0x80
        }
        bytes.append(last)
        let value: Int32 = Data(bytes).to(Int32.self)
        return isNegative ? -value : value
    }
    
}

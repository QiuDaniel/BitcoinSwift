//
//  Script+Static.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

extension Script {
    
    public struct Standard {}
    
    public struct LockTime {}
    
    public struct MultSig {}
    
    public struct OpReturn {}
    
    public struct Condition {}
    
    public struct HashedTimeLockedContract {}
    
}

public enum ScriptError: Error {
    case error(String)
}

// MARK: - Standard Script

public extension Script.Standard {
    static func buildP2PK(_ publickeyData: Data) -> Script? {
        return try? Script().append(publickeyData).append(.OP_CHECKSIG)
    }
    
    static func buildP2PKH(_ address: BitcoinAddress) -> Script? {
        return Script(address: address)
    }
    
    static func buildP2SH(_ script: Script) -> Script {
        return script.toP2SH()
    }
    
    static func bulidMultiSig(_ publicKeys: [PublicKey<Secp256k1>]) -> Script? {
        return Script(publicKeys: publicKeys, signaturesRequired: UInt(publicKeys.count))
    }
    
    static func buildMultiSig(_ publicKeys: [PublicKey<Secp256k1>], signaturesRequired: UInt) -> Script? {
        return Script(publicKeys: publicKeys, signaturesRequired: signaturesRequired)
    }
}

// MARK: - LockTime

public extension Script.LockTime {
    // Base
    static func build(_ script: Script, lockDate: Date) -> Script? {
        return try? Script()
            .append(lockDate.bigNumData)
            .append(.OP_CHECKLOCKTIMEVERIFY)
            .append(.OP_DROP)
            .append(script)
    }
    
    static func build(_ script: Script, lockIntervalSinceNow: TimeInterval) -> Script? {
        let lockDate = Date(timeIntervalSinceNow: lockIntervalSinceNow)
        return build(script, lockDate: lockDate)
    }
    
    // P2PKH + LockTime
    static func build(_ address: BitcoinAddress, lockIntervalSinceNow: TimeInterval) -> Script? {
        guard let p2pkh = Script(address: address) else {
            return nil
        }
        return build(p2pkh, lockIntervalSinceNow: lockIntervalSinceNow)
    }

    static func build(address: BitcoinAddress, lockDate: Date) -> Script? {
        guard let p2pkh = Script(address: address) else {
            return nil
        }
        return build(p2pkh, lockDate: lockDate)
    }
}

// MARK: - OP_RETURN

public extension Script.OpReturn {
    static func build(_ text: String) -> Script? {
        let MAX_OP_RETURN_DATA_SIZE: Int = 220
        guard let data = text.data(using: .utf8), data.count <= MAX_OP_RETURN_DATA_SIZE else {
            return nil
        }
        return try? Script()
            .append(.OP_RETURN)
            .append(data)
    }
}

// MARK: - Condition

public extension Script.Condition {
    
    static func build(_ scripts: [Script]) -> Script? {

        guard !scripts.isEmpty else {
            return nil
        }
        guard scripts.count > 1 else {
            return scripts[0]
        }

        var scripts: [Script] = scripts

        while scripts.count > 1 {
            var newScripts: [Script] = []
            while !scripts.isEmpty {
                let script = Script()
                do {
                    if scripts.count == 1 {
                        try script
                            .append(.OP_DROP)
                            .append(scripts.removeFirst())
                    } else {
                        try script
                            .append(.OP_IF)
                            .append(scripts.removeFirst())
                            .append(.OP_ELSE)
                            .append(scripts.removeFirst())
                            .append(.OP_ENDIF)
                    }
                } catch {
                    return nil
                }
                newScripts.append(script)
            }
            scripts = newScripts
        }

        return scripts[0]
    }
}

// MARK: - HTLC

/*
 OP_IF
    [HASHOP] <digest> OP_EQUALVERIFY OP_DUP OP_HASH160 <recipient pubkey hash>
 OP_ELSE
    <num> [TIMEOUTOP] OP_DROP OP_DUP OP_HASH160 <sender pubkey hash>
 OP_ENDIF
 OP_EQUALVERIFYs
 OP_CHECKSIG
*/

public extension Script.HashedTimeLockedContract {
    // Base
    static func build(_ recipient: BitcoinAddress, sender: BitcoinAddress, lockDate: Date, hash: Data, hashOp: HashOperator) -> Script? {
        guard hash.count == hashOp.hashSize else {
            return nil
        }

        return try? Script()
            .append(.OP_IF)
                .append(hashOp.code)
                .append(hash)
                .append(.OP_EQUALVERIFY)
                .append(.OP_DUP)
                .append(.OP_HASH160)
                .append(recipient.data)
            .append(.OP_ELSE)
                .append(lockDate.bigNumData)
                .append(.OP_CHECKLOCKTIMEVERIFY)
                .append(.OP_DROP)
                .append(.OP_DUP)
                .append(.OP_HASH160)
                .append(sender.data)
            .append(.OP_ENDIF)
            .append(.OP_EQUALVERIFY)
            .append(.OP_CHECKSIG)
    }

    // convenience
    static func build(_ recipient: BitcoinAddress, sender: BitcoinAddress, lockIntervalSinceNow: TimeInterval, hash: Data, hashOp: HashOperator) -> Script? {
        let lockDate = Date(timeIntervalSinceNow: lockIntervalSinceNow)
        return build(recipient, sender: sender, lockDate: lockDate, hash: hash, hashOp: hashOp)
    }

    static func build(_ recipient: BitcoinAddress, sender: BitcoinAddress, lockIntervalSinceNow: TimeInterval, secret: Data, hashOp: HashOperator) -> Script? {
        let hash = hashOp.hash(secret)
        return build(recipient, sender: sender, lockIntervalSinceNow: lockIntervalSinceNow, hash: hash, hashOp: hashOp)
    }

    static func build(_ recipient: BitcoinAddress, sender: BitcoinAddress, lockDate: Date, secret: Data, hashOp: HashOperator) -> Script? {
        let hash = hashOp.hash(secret)
        return build(recipient, sender: sender, lockDate: lockDate, hash: hash, hashOp: hashOp)
    }
}

extension Script {
    
    public static func isPublicKeyHashOut(_ script: Data) -> Bool {
        return script.count == 25 &&
            script[0] == OPCode.OP_DUP && script[1] == OPCode.OP_HASH160 && script[2] == 20 &&
            script[23] == OPCode.OP_EQUALVERIFY && script[24] == OPCode.OP_CHECKSIG
    }

    public static func getPublicKeyHash(from script: Data) -> Data? {
        guard isPublicKeyHashOut(script) else {
            return nil
        }
        return script[3..<23]
    }
    
    // Standard Transaction to Bitcoin address (pay-to-pubkey-hash)
    // scriptPubKey: OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
    public static func p2pkhScript(_ pubKeyHash: Data) throws -> Script {
        let script = try Script()
            .append(.OP_DUP)
            .append(.OP_HASH160)
            .append(pubKeyHash)
            .append(.OP_EQUALVERIFY)
            .append(.OP_CHECKSIG)
        return script
    }
    
    // OP_HASH160 <hash> OP_EQUAL
    public static func p2shScript(_ pubKeyHash: Data) throws -> Script {
        let script = try Script().append(.OP_HASH160).append(pubKeyHash).append(.OP_EQUAL)
        return script
    }
    
    static func parse(_ data: Data) throws -> [ScriptChunk] {
        guard !data.isEmpty else {
            return [ScriptChunk]()
        }
        var chunks = [ScriptChunk]()
        var i: Int = 0
        let length = data.count
        while i < length {
            // Exit if failed to parse
            let chunk = try parse(from: data, offset: i)
            chunks.append(chunk)
            i += chunk.range.count
        }
        return chunks
    }
    
    /// Script
    /// - Parameters:
    ///   - data: data
    ///   - length: Valid values: -1, 0, 1, 2, 4.
    /// - Returns: nil if EncodingLength can't be used for data, or data is nil or too big.
    static func script(forData data: Data, encodingLength length: Int) -> Data? {
        precondition([-1, 0, 1, 2, 4].contains(length), "Valid values: -1, 0, 1, 2, 4.")
        var scriptData: Data = .empty
        if data.count < OPCode.OP_PUSHDATA1 && length <= 0 {
            scriptData += Data(UInt8(data.count))
        } else if data.count <= 0xff && (length == -1 || length == 1) {
            scriptData += Data(OPCode.OP_PUSHDATA1.value)
            scriptData += Data(UInt8(data.count))
        } else if data.count <= 0xffff && (length == -1 || length == 2) {
            scriptData += Data(OPCode.OP_PUSHDATA2.value)
            scriptData += UInt16(data.count).data
        } else if UInt64(data.count) <= 0xffffffff && (length == -1 || length == 4) {
            scriptData += Data(OPCode.OP_PUSHDATA4.value)
            scriptData += UInt64(data.count).data
        } else {
            return nil
        }
        scriptData += data
        return scriptData
    }
    
    static func parse(from scriptData: Data, offset: Int) throws -> ScriptChunk {
        guard scriptData.count > offset else {
            throw ScriptError.error("Parse ScriptChunk failed. Offset is out of range.")
        }
        let opcode: UInt8 = scriptData[offset]
        if opcode > OPCode.OP_PUSHDATA4 {
            let range = offset..<(offset + MemoryLayout.size(ofValue: opcode))
            return OPCodeChunk(scriptData: scriptData, range: range)
        } else {
            return try parseDataChunk(from: scriptData, offset: offset, code: opcode)
        }
    }
    
}

private extension Script {
    
    static func parseDataChunk(from scriptData: Data, offset: Int, code: UInt8) throws -> DataChunk {
        let count = scriptData.count
        let codeSize = MemoryLayout<UInt8>.size
        let dataLengthSize: Int
        let dataSize: Int
        
        var chunkLength: Int {
            return codeSize + dataLengthSize + dataSize
        }
        
        switch code {
        case 0..<OPCode.OP_PUSHDATA1.value:
            dataLengthSize = 0
            dataSize = Int(code)
        case OPCode.OP_PUSHDATA1.value:
            dataLengthSize = MemoryLayout<UInt8>.size
            guard offset + codeSize + dataLengthSize <= count else {
                throw ScriptError.error("Parse DataChunk failed. OP_PUSHDATA1 error")
            }
            dataSize = scriptData.withUnsafeBytes{
                Int($0.load(fromByteOffset: offset + codeSize, as: UInt8.self))
            }
        case OPCode.OP_PUSHDATA2.value:
            dataLengthSize = MemoryLayout<UInt16>.size
            guard offset + codeSize + dataLengthSize <= count else {
                throw ScriptError.error("Parse DataChunk failed. OP_PUSHDATA2 error")
            }
            dataSize = scriptData.withUnsafeBytes{
                Int(CFSwapInt16LittleToHost($0.load(fromByteOffset: offset + codeSize, as: UInt16.self)))
            }
        case OPCode.OP_PUSHDATA4.value:
            dataLengthSize = MemoryLayout<UInt32>.size
            guard offset + codeSize + dataLengthSize <= count else {
                throw ScriptError.error("Parse DataChunk failed. OP_PUSHDATA4 error")
            }
            dataSize = scriptData.withUnsafeBytes{
                Int(CFSwapInt32LittleToHost($0.load(fromByteOffset: offset + codeSize, as: UInt32.self)))
            }
        default:
            // cannot happen because it's opcode
            throw ScriptError.error("Parse DataChunk failed. OP_CODE: \(code).")
        }
        
        guard offset + chunkLength <= count else {
            throw ScriptError.error("Parse DataChunk failed. Push data is out of bounds error.")
        }
        
        let range = offset..<(offset + chunkLength)
        return DataChunk(scriptData: scriptData, range: range)
    }
    
}

public protocol HashOperator {
    var code: OPCode { get }
    var hashSize: Int { get }
    func hash(_ data: Data) -> Data
    
}

public struct HashOperatorSha256: HashOperator {
    public var code: OPCode { return .OP_SHA256 }
    public var hashSize: Int { return 32 }

    public func hash(_ data: Data) -> Data {
        return Crypto.sha256(data)
    }
}

public struct HashOperatorHash160: HashOperator {
    public var code: OPCode { return .OP_HASH160 }
    public var hashSize: Int { return 20 }

    public func hash(_ data: Data) -> Data {
        return Crypto.hash160(data)
    }
}

    /**
public class HashOperator {
    public static let SHA256: HashOperator = HashOperatorSha256()
    public static let HASH160: HashOperator = HashOperatorHash160()

    public var code: OPCode { return .OP_INVALIDOPCODE }
    public var hashSize: Int { return 0 }
    public func hash(_ data: Data) -> Data { return Data() }
    fileprivate init() {}
}

final public class HashOperatorSha256: HashOperator {
    override public var code: OPCode { return .OP_SHA256 }
    override public var hashSize: Int { return 32 }

    override public func hash(_ data: Data) -> Data {
        return Crypto.sha256(data)
    }
}

final public class HashOperatorHash160: HashOperator {
    override public var code: OPCode { return .OP_HASH160 }
    override public var hashSize: Int { return 20 }

    override public func hash(_ data: Data) -> Data {
        return Crypto.hash160(data)
    }
}
     */

// MARK: - Utility Extension
private extension Date {
    var bigNumData: Data {
        let dateUnix: TimeInterval = timeIntervalSince1970
        return encodeNum(Int32(dateUnix).littleEndian)
    }
}

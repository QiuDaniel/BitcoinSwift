//
//  Script.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/29.
//

import Foundation

public class Script {
    
    private var chunks: [ScriptChunk]
    private var dataCache: Data?
    private var stringCache: String?
    
    // Multisignature script attribute.
    // If multisig script is not detected, this is nil
    public typealias MultisigVariables = (nSigRequired: UInt, publickeys: [PublicKey<Secp256k1>])
    public var multisigRequirements: MultisigVariables?

    
    public var data: Data {
        if let cache = dataCache {
            return cache
        }
        dataCache = chunks.reduce(Data.empty) { $0 + $1.chunkData }
        return dataCache!
    }
    
    public var string: String {
        if let cache = stringCache {
            return cache
        }
        let cache = chunks.map { $0.string }.joined(separator: " ")
        stringCache = cache
        return cache
    }
    
    public var hex: String {
        return data.hex
    }
    
    public var scriptChunks: [ScriptChunk] {
        return chunks
    }
    
    public var isP2PKScript: Bool {
        guard chunks.count == 2 else {
            return false
        }
        guard let pushdata = pushedData(at: 0) else {
            return false
        }
        return pushdata.count > 1 && code(at: 1) == .OP_CHECKSIG
    }
    
    public var isP2PKHScript: Bool {
        guard chunks.count == 5 else {
            return false
        }
        guard let dataChunk = chunk(at: 2) as? DataChunk else {
            return false
        }
        
        return code(at: 0) == .OP_DUP && code(at: 1) == .OP_HASH160 && dataChunk.pushedData.count == 20 && code(at: 3) == .OP_EQUALVERIFY && code(at: 4) == .OP_CHECKSIG
    }
    
    public var isP2SHScript: Bool {
        guard chunks.count == 3 else {
            return false
        }
        guard let dataChunk = chunk(at: 1) as? DataChunk else { return false }
        return code(at: 0) == .OP_HASH160 && dataChunk.pushedData.count == 20 && code(at: 2) == .OP_EQUAL
    }
    
    public var isP2WPKHScript: Bool {
        guard chunks.count == 2 else {
            return false
        }
        guard let dataChunk = chunk(at: 1) as? DataChunk else {
            return false
        }
        return code(at: 0) == .OP_0 && dataChunk.pushedData.count == 20
    }
    
    public var isP2WSHScript: Bool {
        guard chunks.count == 2 else {
            return false
        }
        guard let dataChunk = chunk(at: 1) as? DataChunk else {
            return false
        }
        return code(at: 0) == .OP_0 && dataChunk.pushedData.count == 32
    }
    
    public var isMultisignatureScript: Bool {
        guard let requirements = multisigRequirements else {
            return false
        }
        if requirements.nSigRequired == 0 {
            do {
                try detectMultisigScript()
            } catch {
                return false
            }
        }
        return requirements.nSigRequired > 0
        
    }
    
    public var isStandardMultisignatureScript: Bool {
        guard isMultisignatureScript else {
            return false
        }
        guard let multisigPublicKeys = multisigRequirements?.publickeys else { return false }
        return multisigPublicKeys.count <= 3
    }
    
    public var isStandardOpReturnScript: Bool {
        guard chunks.count == 2 else {
            return false
        }
        return code(at: 0) == .OP_RETURN
            && pushedData(at: 1) != nil
    }
    
    // Include both PUSHDATA ops and OP_0..OP_16 literals.
    public var isDataOnly: Bool {
        return !chunks.contains { $0.value > OPCode.OP_16 }
    }
    
    public init(_ chunks: [ScriptChunk]? = nil) {
        if chunks == nil {
            self.chunks = [ScriptChunk]()
        } else {
            self.chunks = chunks!
        }
    }
    
    public convenience init?(_ data: Data) {
        do {
            let chunks = try Script.parse(data)
            self.init(chunks)
        } catch {
            return nil
        }
    }
    
    public convenience init?(hex: String) {
        let data = Data(hex: hex)
        self.init(data)
    }
    
    public convenience init?(address: BitcoinAddress) {
        self.init()
        switch address.hashType {
        case .pubkeyHash:
            // OP_DUP OP_HASH160 <hash> OP_EQUALVERIFY OP_CHECKSIG
            do {
                try self.append(.OP_DUP)
                    .append(.OP_HASH160)
                    .append(address.data)
                    .append(.OP_EQUALVERIFY)
                    .append(.OP_CHECKSIG)
            } catch {
                return nil
            }
        case .scriptHash:
            // OP_HASH160 <hash> OP_EQUAL
            do {
                try self.append(.OP_HASH160)
                    .append(address.data)
                    .append(.OP_EQUAL)
            } catch {
                return nil
            }
        }
    }
    
    // OP_<M> <pubkey1> ... <pubkeyN> OP_<N> OP_CHECKMULTISIG
    public convenience init?(publicKeys: [PublicKey<Secp256k1>], signaturesRequired: UInt) {
        // First make sure the arguments make sense.
        // We need at least one signature
        guard signaturesRequired > 0 else {
            return nil
        }

        // And we cannot have more signatures than available pubkeys.
        guard publicKeys.count >= signaturesRequired else {
            return nil
        }

        // Both M and N should map to OP_<1..16>
        let mOpcode = OPCode.parseSmallInteger(Int(signaturesRequired))
        let nOpcode = OPCode.parseSmallInteger(publicKeys.count)

        guard mOpcode != .OP_INVALIDOPCODE else {
            return nil
        }
        guard nOpcode != .OP_INVALIDOPCODE else {
            return nil
        }
        do {
            self.init()
            try append(mOpcode)
            for pubkey in publicKeys {
                try append(pubkey.data)
            }
            try append(nOpcode)
            try append(.OP_CHECKMULTISIG)
            multisigRequirements = (signaturesRequired, publicKeys)
        } catch {
            return nil
        }
    }
    
}

// MARK: - Public Method

public extension Script {
    
    func toP2SH() -> Script {
        return try! Script()
            .append(.OP_HASH160)
            .append(Crypto.hash160(data))
            .append(.OP_EQUAL)
    }
    
    func address(_ network: Network = .BTCmainnet) -> BitcoinAddress? {
        if isP2PKHScript, let pubkeyHash = pushedData(at: 2) {
            return BitcoinAddress(data: pubkeyHash, network: network, hashType: .pubkeyHash)
        } else if isP2SHScript, let scriptHash = pushedData(at: 1) {
            return BitcoinAddress(data: scriptHash, network: network, hashType: .scriptHash)
        }
        return nil
    }
    
    func standardOpReturnData() -> Data? {
        guard isStandardOpReturnScript else {
            return nil
        }
        return pushedData(at: 1)
    }
    
    func serialize() -> Data {
        let data = rawSerialize()
        let varInt = VarInt(data.count)
        return varInt.data + data
    }
    
    func excute(_ context: ScriptExcutionContext) throws {
        try chunks.forEach { chunk in
            if let opChunk = chunk as? OPCodeChunk {
                try opChunk.code.excute(context)
            } else if let dataChunk = chunk as? DataChunk {
                if context.shouldExcute {
                    try context.push(dataChunk.pushedData)
                }
            } else {
                throw ScriptError.error("unknow chunk")
            }
        }
        guard context.conditionStack.isEmpty else {
            throw ScriptError.error("Condition branches not balanced.")
        }
    }
    
    @discardableResult
    func append(_ code: OPCode) throws -> Script {
        let invalidCodes: [OPCode] = [.OP_PUSHDATA1, .OP_PUSHDATA2, .OP_PUSHDATA4, .OP_INVALIDOPCODE]
        guard !invalidCodes.contains(where: { $0 == code }) else {
            throw ScriptError.error("\(code.name) cannot be executed alone.")
        }
        var updateData = data
        updateData += Data(code.value)
        try update(with: updateData)
        return self
    }
    
    @discardableResult
    func append(_ data: Data) throws -> Script {
        guard !data.isEmpty else {
            throw ScriptError.error("Data is empty")
        }
        guard let addedScriptData = Script.script(forData: data, encodingLength: -1) else {
            throw ScriptError.error("Parse data to pushdata failed.")
        }
        var updateData = self.data
        updateData += addedScriptData
        try update(with: updateData)
        return self
    }
    
    @discardableResult
    func append(_ script: Script) throws -> Script {
        guard !script.data.isEmpty else {
            throw ScriptError.error("Script is empty")
        }
        var updateData = data
        updateData += script.data
        try update(with: updateData)
        return self
    }

    
    @discardableResult
    func deleteOccurrences(of code: OPCode) throws -> Script {
        let updatedData = chunks.filter { $0.code != code }.reduce(Data.empty) { $0 + $1.chunkData }
        try update(with: updatedData)
        return self
    }
}

// MARK: - Private Method

private extension Script {
    
    // If typical multisig tx is detected, sets requirements:
    private func detectMultisigScript() throws {
        // multisig script must have at least 4 ops ("OP_1 <pubkey> OP_1 OP_CHECKMULTISIG")
        guard chunks.count >= 4 else {
            return
        }

        // The last op is multisig check.
        guard code(at: -1) == .OP_CHECKMULTISIG else {
            return
        }

        let mOpcode = code(at: 0)
        let nOpcode = code(at: -2)

        let m: Int = OPCode.smallInteger(from: mOpcode)
        let n: Int = OPCode.smallInteger(from: nOpcode)

        guard m > 0 && m != Int.max else {
            return
        }
        guard n > 0 && n != Int.max && n >= m else {
            return
        }

        // We must have correct number of pubkeys in the script. 3 extra ops: OP_<M>, OP_<N> and OP_CHECKMULTISIG
        guard chunks.count == 3 + n else {
            return
        }

        var pubkeys: [PublicKey<Secp256k1>] = []
        for i in 0...n {
            guard let data = pushedData(at: i) else {
                return
            }
            let pubkey = try PublicKey<Secp256k1>(bytes: data)
            pubkeys.append(pubkey)
        }

        // Now we extracted all pubkeys and verified the numbers.
        multisigRequirements = (UInt(m), pubkeys)
    }
    
    func rawSerialize() -> Data {
        return data
    }

    func chunk(at i: Int) -> ScriptChunk {
        let index = i < 0 ? chunks.count + i : i
        
        return chunks[index]
    }
    
    func code(at i: Int) -> OPCode {
        let chunk = chunk(at: i)
        guard chunk is OPCodeChunk else {
            return .OP_INVALIDOPCODE
        }
        return chunk.code
    }
    
    func pushedData(at i: Int) -> Data? {
        let chunk = chunk(at: i)
        return (chunk as? DataChunk)?.pushedData
    }
    
    func invalidateSerialization() {
        dataCache = nil
        stringCache = nil
        multisigRequirements = nil
    }
    
    func update(with updatedData: Data) throws {
        let updataeChunks = try Script.parse(updatedData)
        chunks = updataeChunks
        invalidateSerialization()
    }
    
    @discardableResult
    func deleteOccurrences(of data: Data) throws -> Script {
        guard !data.isEmpty else {
            return self
        }

        let updatedData = chunks.filter { ($0 as? DataChunk)?.pushedData != data }.reduce(Data.empty) { $0 + $1.chunkData }
        try update(with: updatedData)
        return self
    }

    
    func `subscript`(from index: Int) throws -> Script {
        if index >= chunks.count || index < 0 {
            throw ScriptError.error("index out of bounds")
        }
        let tmpChunk = Array(chunks[index..<chunks.count])
        return Script(tmpChunk)
    }
    
    func `subscript`(to index: Int) throws -> Script {
        precondition(index >= 1, "index need greater than or equal 1.")
        if index >= chunks.count {
            throw ScriptError.error("index out of bounds")
        }
        let tmpChunk = Array(chunks[0..<index])
        return Script(tmpChunk)
    }
}

extension Script: CustomStringConvertible {
    public var description: String {
        return string
    }
}

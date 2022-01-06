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

extension Script {
    
    static func parse(_ data: Data) throws -> [ScriptChunk] {
        guard !data.isEmpty else {
            return [ScriptChunk]()
        }
        var chunks = [ScriptChunk]()

        var i: Int = 0
        let count: Int = data.count

        while i < count {
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

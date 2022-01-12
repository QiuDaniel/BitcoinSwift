//
//  ScriptChunk.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

/**
 OP_1NEGATE, OP_0, OP_1..OP_16 are represented as a decimal number.
 Most compactly represented pushdata chunks >=128 bit are encoded as <hex string>
 Smaller most compactly represented data is encoded as [<hex string>]
 Non-compact pushdata (e.g. 75-byte string with PUSHDATA1) contains a decimal prefix denoting a length size before hex data in square brackets. Ex. "1:[...]", "2:[...]" or "4:[...]"
 For both compat and non-compact pushdata chunks, if the data consists of all printable characters (0x20..0x7E), it is enclosed not in square brackets, but in single quotes as characters themselves. Non-compact string is prefixed with 1:, 2: or 4: like described above.

 Some other guys (BitcoinQT, bitcoin-ruby) encode "small enough" integers in decimal numbers and do that differently.
 BitcoinQT encodes any data less than 4 bytes as a decimal number.
 bitcoin-ruby encodes 2..16 as decimals, 0 and -1 as opcode names and the rest is in hex.
 Now no matter which encoding you use, it can be parsed incorrectly.
 Also: pushdata operations are typically encoded in a raw data which can be encoded in binary differently.
 This means, you'll never be able to parse a sane-looking script into only one binary.
 So forget about relying on parsing this thing exactly. Typically, we either have very small numbers (0..16),
 or very big numbers (hashes and pubkeys).
 */

public protocol ScriptChunk {
    
    // Reference to the whole script binary data.
    var scriptData: Data { get }
    // A range of scriptData represented by this chunk.
    var range: Range<Int> { get }

    // Portion of scriptData defined by range.
    var chunkData: Data { get }
    // OP_CODE of scriptData defined by range.
    var code: OPCode { get }
    // String representation of a chunk.
    var string: String { get }
    
    func updated(_ scriptData: Data) -> ScriptChunk
    
    func updated(_ scriptData: Data, range updatedRange: Range<Int>) -> ScriptChunk
}

public extension ScriptChunk {
    
    var value: UInt8 {
        return UInt8(scriptData[range.lowerBound])
    }
    
    var code: OPCode {
        return OPCode.parse(value)
    }
    
    var chunkData: Data {
        return scriptData.subdata(in: range)
    }
}


public struct OPCodeChunk: ScriptChunk {
    
    public let scriptData: Data
    public let range: Range<Int>
    
    public var string: String {
        return code.name
    }
    
    public func updated(_ scriptData: Data) -> ScriptChunk {
        return OPCodeChunk(scriptData: scriptData, range: range)
    }
    
    public func updated(_ scriptData: Data, range updatedRange: Range<Int>) -> ScriptChunk {
        return OPCodeChunk(scriptData: scriptData, range: updatedRange)
    }
    
}

public struct DataChunk: ScriptChunk {
    
    public let scriptData: Data
    public let range: Range<Int>
    
    public var pushedData: Data {
        return data
    }

    public var string: String {
        var str: String
        guard !data.isEmpty else {
            return "OP_0"
        }
        if data.isASCII {
            str = String(data: data, encoding: .default)!
            
            // Escape escapes & single quote characters.
            str = str.replacingOccurrences(of: "\\", with: "\\\\")
            str = str.replacingOccurrences(of: "'", with: "\\'")
            str = "'" + str + "'"
        } else {
            str = data.hex
            // Shorter than 128-bit chunks are wrapped in square brackets to avoid ambiguity with big all-decimal numbers.
            if data.count < 16 {
                str = "[\(str)]"
            }
        }
        
        if !isCompact {
            var prefix = 1
            switch code {
            case .OP_PUSHDATA2:
                prefix = 2
            case .OP_PUSHDATA4:
                prefix = 4
            default:
                break
            }
            str = String(prefix) + ":" + str
        }
        return str
    }
    
    public func updated(_ scriptData: Data) -> ScriptChunk {
        return DataChunk(scriptData: scriptData, range: range)
    }
    
    public func updated(_ scriptData: Data, range updatedRange: Range<Int>) -> ScriptChunk {
        return DataChunk(scriptData: scriptData, range: updatedRange)
    }
    
}

private extension DataChunk {
    
    var data: Data {
        var location = 1
        switch code {
        case .OP_PUSHDATA1:
            location += 1
        case .OP_PUSHDATA2:
            location += 2
        case .OP_PUSHDATA4:
            location += 4
        default:
            break
        }
        return scriptData.subdata(in: (range.lowerBound + location)..<range.upperBound)
    }
    
    var isCompact: Bool {
        switch code.value {
        case ...OPCode.OP_PUSHDATA1.value:
            return true // length fits in one byte under OP_PUSHDATA1.
        case OPCode.OP_PUSHDATA1.value:
            return data.count >= OPCode.OP_PUSHDATA1.value // length should not be less than OP_PUSHDATA1
        case OPCode.OP_PUSHDATA2.value:
            return data.count > (0xff) // length should not fit in one byte
        case OPCode.OP_PUSHDATA4.value:
            return data.count > (0xffff) // length should not fit in two bytes
        default:
            return false
        }
    }
}

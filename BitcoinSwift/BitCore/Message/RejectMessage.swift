//
//  RejectMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/8.
//

import Foundation


// https://github.com/bitcoin/bips/blob/master/bip-0061.mediawiki

public struct RejectMessage {
    
    public static let command = "reject"
    
    /// Message that triggered the reject
    public let message: VarString
    /// code relating to rejected message
    /// 0x01    Message could not be decoded
    /// 0x10    Transaction is invalid for some reason (invalid signature, output value greater than input, etc.)
    /// 0x11    Block's version is no longer supported
    /// 0x12    An input is already spent
    /// 0x40    Not mined/relayed because it is "non-standard" (type or version unknown by the server)
    /// 0x41    One or more output amounts are below the 'dust' threshold
    /// 0x42    Transaction does not have enough fee/priority to be relayed or mined
    /// 0x43    Inconsistent with a compiled-in checkpoint
    public let code: UInt8
    /// Human-readable message for debugging
    public let reason: VarString
    /// transaction that is rejected or block (hash of block header) that is rejected, so the field is 32 bytes.
    public let hash: Data
    
    public static func parse(_ stream: ByteStream) -> Self {
        let message = stream.read(VarString.self)
        let code = stream.read(UInt8.self)
        let reason = stream.read(VarString.self)
        return .init(message: message, code: code, reason: reason, hash: .empty)
    }
}

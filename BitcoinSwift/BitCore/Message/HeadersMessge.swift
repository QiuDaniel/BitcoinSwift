//
//  HeadersMessge.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/13.
//

import Foundation

public struct HeadersMessage {
    
    public static let command = "headers"
    
    // The main client will never send us more than this number of headers.
    public static let MAX_HEADERS: Int = 2000
    
    public let headers: [Block]
    
    func serialize() -> Data {
        var result = VarInt(headers.count).serialize()
        result += headers.flatMap{ $0.serialize() + Data(0x00) }
        return result
    }
    
    static func parse(_ stream: ByteStream) throws -> Self {
        let headersNum = stream.read(VarInt.self).underlyingValue
        guard headersNum <= MAX_HEADERS else {
            throw MessageError.error("Too many headers: got \(headersNum) which is larger than \(MAX_HEADERS)")
        }
        var blocks = [Block]()
        for _  in 0..<headersNum {
            let block = Block.parse(stream)
            blocks.append(block)
            let txNum = stream.read(VarInt.self).underlyingValue
            if txNum != 0 {
                throw MessageError.error("Block header does not have transaction")
            }
        }
        return .init(headers: blocks)
    }
    
}

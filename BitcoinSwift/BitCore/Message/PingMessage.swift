//
//  PingMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import Foundation

public struct PingMessage {
    
    public static let command = "ping"
    
    public let nonce: UInt64
    
    func serialize() -> Data {
        return nonce.data
    }
    
    static func parse(_ stream: ByteStream) -> Self {
        let nonce = stream.read(UInt64.self)
        return .init(nonce: nonce)
    }
    
}

//
//  AddressMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/9.
//

import Foundation

public struct AddressMessage {
    
    public static let command = "addr"
    
    public let addresses: [NetworkAddress]
    
    public static func parse(_ stream: ByteStream) -> Self {
        let count = stream.read(VarInt.self).underlyingValue
        var addresses = [NetworkAddress]()
        for _ in 0..<count {
            _ = stream.read(UInt32.self) // timestamp
            addresses.append(NetworkAddress.parse(stream))
        }
        return .init(addresses: addresses)
    }
}

//
//  InventoryMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/8.
//

import Foundation

public struct InventoryMessage {
    public static let command = "inv"
    
    public let entries: [Inventory]
    
    public func serialize() -> Data {
        var result = Data.empty
        result += VarInt(entries.count).serialize()
        result += entries.flatMap { $0.serialize() }
        return result
    }
    
    public static func parse(_ stream: ByteStream) -> Self {
        let count = stream.read(VarInt.self).underlyingValue
        var entries = [Inventory]()
        for _ in 0..<count {
            entries.append(Inventory.parse(stream))
        }
        return .init(entries: entries)
    }
}

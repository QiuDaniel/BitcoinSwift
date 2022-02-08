//
//  Inventory.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/8.
//

import Foundation

public enum GetDataType: Int32 {
    case error = 0
    case transaction = 1
    case block = 2
    case filtered = 3
    case compact = 4
    case unknown
}

public struct Inventory {
    public let type: GetDataType
    public let identifier: Data
    
    
    func serialize() -> Data {
        var result = type.rawValue.littleEndian.data
        result += identifier.reversed()
        return result
    }
    
    static func parse(_ stream: ByteStream) -> Self {
        let type = stream.read(Int32.self)
        let identifier = Data(stream.read(Data.self, count: 32).reversed())
        return .init(type: GetDataType(rawValue: type)!, identifier: identifier)
    }
}

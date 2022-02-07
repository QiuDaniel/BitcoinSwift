//
//  GetDataMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/13.
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

public typealias Inventory = (GetDataType, Data)

public struct GetDataMessage {
    public let datas: [Inventory]
    

    
    public func serialize() throws -> Data {
        var result = VarInt(datas.count).serialize()
        result += try datas.flatMap{ (type, identifier) -> Data in
            if type.rawValue < 1 && type.rawValue > 4 {
                throw BitCoreError.valueError("wrong GetDataType")
            }
            var data = type.rawValue.littleEndian.data
            data += identifier.reversed()
            return data
        }
        return result
    }
    
    public static func parse(_ stream: ByteStream) throws -> GetDataMessage {
        let count = stream.read(VarInt.self).underlyingValue
        var datas = [Inventory]()
        for _ in 0..<count {
            let type = stream.read(Int32.self)
            if type < 1 && type > 4 {
                throw BitCoreError.valueError("wrong GetDataType")
            }
            let identifier = Data(stream.read(Data.self, count: 32).reversed())
            datas.append((GetDataType(rawValue: type)!, identifier))
        }
        return GetDataMessage(datas: datas)
    }
}

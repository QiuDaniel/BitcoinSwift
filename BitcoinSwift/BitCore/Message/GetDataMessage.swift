//
//  GetDataMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/13.
//

import Foundation

public struct GetDataMessage {
    
    public static let command = "getdata"
    
    public let datas: [Inventory]
    

    public func serialize() -> Data {
        var result = VarInt(datas.count).serialize()
        result +=  datas.flatMap{ $0.serialize() }
        return result
    }
    
    public static func parse(_ stream: ByteStream) -> GetDataMessage {
        let count = stream.read(VarInt.self).underlyingValue
        var datas = [Inventory]()
        for _ in 0..<count {
            datas.append(Inventory.parse(stream))
        }
        return GetDataMessage(datas: datas)
    }
}

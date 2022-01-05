//
//  Base58Check.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/22.
//

import Foundation

public struct Base58Check {
    
    static func encode(_ data: Data) -> String {
        return Base58.encode(data + Crypto.hash256(data).prefix(maxCount: 4))
    }
    
    static func decode(_ string: String) -> Data? {
        guard let decodeBytes = Base58.decode(string) else {
            return nil
        }
        let checksum = decodeBytes.suffix(4)
        let payload = decodeBytes.dropLast(4)
        if Crypto.hash256(payload).prefix(maxCount: 4) != checksum {
            return nil
        }
        return payload
    }
    
}

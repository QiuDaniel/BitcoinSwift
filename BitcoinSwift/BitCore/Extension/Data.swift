//
//  Data.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2021/12/22.
//

// copy from https://github.com/krzyzanowskim/CryptoSwift/blob/main/Sources/CryptoSwift/Foundation/Data%2BExtension.swift

extension Data {
    
    public static var empty: Data {
        return Data()
    }
    
    public var isASCII: Bool {
        for ch in self {
            if !(ch >= 0x20 && ch <= 0x7e) {
                return false
            }
        }
        return true
    }
    
    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
    
    public init(_ byte: UInt8) {
        self.init([byte])
    }

    public var bytes: Array<UInt8> {
        Array(self)
    }

    public func toHexString() -> String {
        self.bytes.toHexString()
    }
}


//
//  GenericMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import Foundation

public struct GenericMessage {
    public let command: String
    public let payload: Data
    
    public func serialize() -> Data {
        return payload
    }
}

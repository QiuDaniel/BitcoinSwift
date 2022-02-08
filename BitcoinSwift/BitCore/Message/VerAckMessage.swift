//
//  VerAckMessage.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import Foundation

public struct VerAckMessage {
    
    public static let command = "verack"
    
    func serialize() -> Data {
        return .empty
    }
    
}

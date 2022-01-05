//
//  OP_PUSHDATA.swift
//  BitCore
//
//  Created by SPARK-Daniel on 2022/1/5.
//

import Foundation

// The next 1-byte contains the number of bytes to be pushed onto the stack (allows pushing 0..255 bytes).
public struct OpPushData1: OpCodeType {
    public var value: UInt8 { return 0x4c }
    public var name: String { return "OP_PUSHDATA1" }
}

// The next 2-bytes contain the number of bytes to be pushed onto the stack in little endian order (allows pushing 0..65535 bytes).
public struct OpPushData2: OpCodeType {
    public var value: UInt8 { return 0x4d }
    public var name: String { return "OP_PUSHDATA2" }
}

// The next 4-bytes contain the number of bytes to be pushed onto the stack in little endian order (allows pushing 0..4294967295 bytes)
public struct OpPushData4: OpCodeType {
    public var value: UInt8 { return 0x4e }
    public var name: String { return "OP_PUSHDATA4" }
}

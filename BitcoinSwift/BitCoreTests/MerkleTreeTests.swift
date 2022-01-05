//
//  MerkleTreeTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2021/12/30.
//

import XCTest
@testable import BigInt
@testable import BitCore

class MerkleTreeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMerkleTree() {
        let root = "d4142d690dbd473b3eb83a0171799011743e53ca06228975c295d42eef5f44ef"
        let hexHashes = [
            "8a08dcc58ed305c3dba6e4c161a67ae8ffec2b56c972301770e380140d2a41ba",
            "7de2e15e65389a6480cee02af76be0378cc9c2f918e8da2eb3a7ac58642ef97c",
            "c2c2c8df2a2d53eb4f4a432380abf9a772d5e92340b9242f73160b941d42d934",
            "ba4c2c2280c2725def0d401772896298133ec14bc5862edf99eb04bdd1858715",
            "ce6327f982624be78f9d917b3fda5ffc06e59f3e8582fab8db50151e836172ee",
            "9750f2d4abce7063e7513cc7d9ec51d0c22b839b362ac319867caf77f925e6f8",
            "8dcb9db66e8654c5f157b42b6e6f42fe6bac08e65d4253ed04d498a87f5956c2",
            "4325eaa2383fbde420ac7d69c6daf4accaea0e06c7e653d03c9ba5e980f8f66b",
            "4c2717f99abeee84838402bd46cf5a828cb5f5671c1ef8a9900743e35379abd1",
            "6122b61c413a297dd486f8549c8d2544d610def0de7779a1238ad5a5281abbdf",
        ]
        
        let hashes = hexHashes.map { Data(Data(hex: $0).reversed()) }
        let flags = Data(hex: "b55635").bytes
        
        let tree = MerkleTree(3519)
        try! tree.populateTree(flagBits: bytes2bitField(flags), hashes: hashes)
        let rootHex = Data(tree.root.hash!.reversed()).toHexString()
        XCTAssertEqual(rootHex, root)
    }
    
    func testBytes2Bits() {
        let flagBitsNum = BigUInt(Data(hex: "b55635"))
        let flagBits = Data(hex: "b55635").bytes
        let numberOfFlags = flagBitsNum.bitWidth
        let tmpBits = (0..<numberOfFlags).compactMap { flagBits[$0 / 8] & UInt8(1 << ($0 % 8)) != 0 ? UInt(1) : UInt(0)}
        let tmpBits1 = bytes2bitField(flagBits)
        XCTAssertTrue(tmpBits == tmpBits1)
    }
    
    func testBits2Bytes() {
        let bits = [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0]
        let bytes = bitField2Bytes(bits.map { UInt($0) })!
        XCTAssertEqual(Data(bytes).toHexString(), "b55635")
    }

}

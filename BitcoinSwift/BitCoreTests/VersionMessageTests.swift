//
//  VersionMessageTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import XCTest
@testable import BitCore

class VersionMessageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSerialize() {
        let v = VersionMessage(timestamp: 0, nonce: UInt64(0))
        XCTAssertEqual(v.serialaize().hex, "7f11010000000000000000000000000000000000000000000000000000000000000000000000ffff00000000208d000000000000000000000000000000000000ffff00000000208d0000000000000000182f70726f6772616d6d696e67626974636f696e3a302e312f0000000000")
        let v1 = VersionMessage.parse(ByteStream(Data(hex: "7f11010000000000000000000000000000000000000000000000000000000000000000000000ffff00000000208d000000000000000000000000000000000000ffff00000000208d0000000000000000182f70726f6772616d6d696e67626974636f696e3a302e312f0000000000")))
        XCTAssertEqual(v.timestamp, v1.timestamp)
        XCTAssertEqual(v.nonce, v1.nonce)
    }

}

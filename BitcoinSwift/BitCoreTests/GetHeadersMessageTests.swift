//
//  GetHeadersMessageTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/12.
//

import XCTest
@testable import BitCore

class GetHeadersMessageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let blockHex = "0000000000000000001237f46acddf58578a37e213d2a6edc4884a2fcad05ba3"
        let gh = GetHeadersMessage(startBlock: Data(hex: blockHex))
        XCTAssertEqual(gh.serialize().hex, "7f11010001a35bd0ca2f4a88c4eda6d213e2378a5758dfcd6af437120000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    }

    

}

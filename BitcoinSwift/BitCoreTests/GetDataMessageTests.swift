//
//  GetDataMessageTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/2/7.
//

import XCTest

@testable import BitCore

class GetDataMessageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSerialize() throws {
        let msgHex = "020300000030eb2540c41025690160a1014c577061596e32e426b712c7ca00000000000000030000001049847939585b0652fba793661c361223446b6fc41089b8be00000000000000"
        let inventory1 = Inventory(type: .filtered, identifier:  Data(hex: "00000000000000cac712b726e4326e596170574c01a16001692510c44025eb30"))
        let inventory2 = Inventory(type: .filtered, identifier: Data(hex: "00000000000000beb88910c46f6b442312361c6693a7fb52065b583979844910"))
        let getData = GetDataMessage(datas: [inventory1, inventory2])
        XCTAssertEqual(getData.serialize(), Data(hex: msgHex))
    }
    
    func testParse() {
        let stream = ByteStream(Data(hex: "020300000030eb2540c41025690160a1014c577061596e32e426b712c7ca00000000000000030000001049847939585b0652fba793661c361223446b6fc41089b8be00000000000000"))
        let getData = GetDataMessage.parse(stream)
        XCTAssertEqual(getData.datas[0].type, GetDataType.filtered)
        XCTAssertEqual(getData.datas[0].identifier, Data(hex: "00000000000000cac712b726e4326e596170574c01a16001692510c44025eb30"))
        XCTAssertEqual(getData.datas[1].type, GetDataType.filtered)
        XCTAssertEqual(getData.datas[1].identifier, Data(hex: "00000000000000beb88910c46f6b442312361c6693a7fb52065b583979844910"))
    }

}

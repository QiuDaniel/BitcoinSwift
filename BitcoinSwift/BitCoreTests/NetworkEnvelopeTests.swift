//
//  NetworkEnvelopeTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/11.
//

import XCTest
@testable import BitCore

class NetworkEnvelopeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParse() {
        let msg = Data(hex: "f9beb4d976657261636b000000000000000000005df6e0e2")
        let envelope = try! NetworkEnvelope.parse(ByteStream(msg))
        XCTAssertEqual(envelope.command, "verack")
        XCTAssertEqual(envelope.payload, Data.empty)
        let msg1 = Data(hex: "f9beb4d976657273696f6e0000000000650000005f1a69d2721101000100000000000000bc8f5e5400000000010000000000000000000000000000000000ffffc61b6409208d010000000000000000000000000000000000ffffcb0071c0208d128035cbc97953f80f2f5361746f7368693a302e392e332fcf05050001")
        let enve1 = try! NetworkEnvelope.parse(ByteStream(msg1))
        XCTAssertEqual(enve1.command, "version")
        XCTAssertEqual(enve1.payload, msg1[24..<msg1.count])
    }
    
    func testSerialize() {
        let msg = Data(hex: "f9beb4d976657261636b000000000000000000005df6e0e2")
        let envelope = try! NetworkEnvelope.parse(ByteStream(msg))
        XCTAssertEqual(envelope.serialize(), msg)
        let msg1 = Data(hex: "f9beb4d976657273696f6e0000000000650000005f1a69d2721101000100000000000000bc8f5e5400000000010000000000000000000000000000000000ffffc61b6409208d010000000000000000000000000000000000ffffcb0071c0208d128035cbc97953f80f2f5361746f7368693a302e392e332fcf05050001")
        let enve1 = try! NetworkEnvelope.parse(ByteStream(msg1))
        XCTAssertEqual(msg1, enve1.serialize())
    }

}

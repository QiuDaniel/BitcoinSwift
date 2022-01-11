//
//  ScriptTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/9.
//

import XCTest
@testable import BitCore

class ScriptTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testParse() {
        let script = Script(hex: "6a47304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a7160121035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937")!
        XCTAssertTrue(script.scriptChunks[0] is DataChunk)
        XCTAssertTrue(script.scriptChunks[1] is DataChunk)
        XCTAssertEqual((script.scriptChunks[0] as! DataChunk).pushedData.hex, "304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a71601")
        XCTAssertEqual((script.scriptChunks[1] as! DataChunk).pushedData.hex, "035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937")
        
    }
    
    func testSerialize() {
        let want = "6a47304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a7160121035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937"
        let script = Script(hex: want)!
        let serialize = script.serialize()
        XCTAssertEqual(serialize.hex, want)
    }
    
    func testAddress() {
        let address1 = "1BenRpVUFK65JFWcQSuHnJKzc4M8ZP8Eqa"
        let h160 = Base58Check.decode(address1)?.dropFirst()
        let pubKey = try! Script.p2pkhScript(h160!)
        XCTAssertEqual(pubKey.address()?.legacy, address1)
        XCTAssertTrue(pubKey.isP2PKHScript)
        
        let address2 = "mrAjisaT4LXL5MzE81sfcDYKU3wqWSvf9q"
        XCTAssertEqual(pubKey.address(.BTCtestnet)?.legacy, address2)
        
        let address3 = "3CLoMMyuoDQTPRD3XYZtCvgvkadrAdvdXh"
        let h160_1 = Base58Check.decode(address3)?.dropFirst()
        let p2shPubkey = try! Script.p2shScript(h160_1!)
        XCTAssertEqual(p2shPubkey.address()?.legacy, address3)
        
        let address4 = "2N3u1R6uwQfuobCqbCgBkpsgBxvr1tZpe7B"
        XCTAssertEqual(p2shPubkey.address(.BTCtestnet)?.legacy, address4)
    }

}

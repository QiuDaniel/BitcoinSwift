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
        let script = Script(hex: "47304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a7160121035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937")!
        XCTAssertTrue(script.scriptChunks[0] is DataChunk)
        XCTAssertTrue(script.scriptChunks[1] is DataChunk)
        XCTAssertEqual((script.scriptChunks[0] as! DataChunk).pushedData.hex, "304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a71601")
        XCTAssertEqual((script.scriptChunks[1] as! DataChunk).pushedData.hex, "035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937")
        
    }
    
    func testSerialize() {
        let want = "6a47304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a7160121035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937"
        let script = Script(hex: "47304402207899531a52d59a6de200179928ca900254a36b8dff8bb75f5f5d71b1cdc26125022008b422690b8461cb52c3cc30330b23d574351872b7c361e9aae3649071c1a7160121035d5c93d9ac96881f19ba1f686f15f009ded7c62efe85a872e6a19b43c15a2937")!
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
    
    func testStandardScript() {
        let script = Script(Data(hex: "76a9147ab89f9fae3f8043dcee5f7b5467a0f0a6e2f7e188ac"))!
        XCTAssertTrue(script.isP2PKHScript, "should be regular hash160 script")
        
        let address = try! BitcoinAddress("1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")
        let script2 = Script(address: address)
        XCTAssertEqual(script2!.data, script.data, "script created from extracted address should be the same as the original script")
        XCTAssertEqual(script2!.string, script.string, "script created from extracted address should be the same as the original script")
    }
    
//    func testCreate2of3MultisigScript() {
//        let aliceKey = try! PrivateKey<Secp256k1>(wif: "cNaP9iG9DaNNemnVa2LXvw4rby5Xc4k6qydENQmLBm2aD7gD7GJi")
//        let bobKey = try! PrivateKey<Secp256k1>(wif: "cSZEkc5cpjjmfK8E9MbTmHwmzck8MokK5Wd9LMTv59qdNSQNGBbG")
//        let charlieKey = try! PrivateKey<Secp256k1>(wif: "cUJiRP3A2KoCVi7fwYBGTKUaiHKgvT9CSiXpoGJdbYP9kEqHKU4q")
//
//        let redeemScript = Script(publicKeys: [aliceKey!.toPublicKey(), bobKey!.toPublicKey(), charlieKey!.toPublicKey()], signaturesRequired: 2)
//        XCTAssertNotNil(redeemScript)
//        let p2shScript = redeemScript!.toP2SH()
//        XCTAssertEqual(p2shScript.hex, "a914629a500c5eaac9261cac990c72241a959ff2d3d987")
//        let multisigAddr = redeemScript!.address(.BTCtestnet)!
////        XCTAssertEqual(multisigAddr.cashaddr, "bchtest:pp3f55qvt64vjfsu4jvscu3yr22eluknmyt3nkwcx2", "multisig address should be the same as address created from bitcoin-ruby.")
//    }

}

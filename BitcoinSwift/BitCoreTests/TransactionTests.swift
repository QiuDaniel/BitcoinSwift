//
//  TransactionTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/10.
//

import XCTest
@testable import BitCore

class TransactionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSerialize() {
        
        let script = Script(hex: "6b483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a")!
        XCTAssertEqual(script.data.hex, "483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a")
        XCTAssertEqual(script.serialize().hex, "6b483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a")
        let input = TransactionInput(prevTx: Data(hex: "d1c789a9c60383bf715f3f6ad9d14b91fe55f3deb369fe5d9280cb1a01793f81"), prevIndex: 0, scriptSig: script, sequence: 0xFFFFFFFE)
        XCTAssertEqual(input.serialize().hex, "813f79011acb80925dfe69b3def355fe914bd1d96a3f5f71bf8303c6a989c7d1000000006b483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278afeffffff")
        let banlance1: UInt64 = 32454049
        let script1 = Script(hex:"1976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac")!
        let script1_1 = try! Script.p2pkhScript(Data(hex: "bc3b654dca7e56b04dca18f2566cdaf02e8d9ada"))
        XCTAssertEqual(script1.data, script1_1.data)
        XCTAssertEqual(script1.serialize().hex, "1976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac")
        let balance2: UInt64 = 10011545
        let script2 = Script(hex:"76a9141c4bc762dd5423e332166702cb75f40df79fea1288ac")!
        let script2_1 = try! Script.p2pkhScript(Data(hex: "1c4bc762dd5423e332166702cb75f40df79fea12"))
        XCTAssertEqual(script2.data, script2_1.data)
        XCTAssertEqual(script2.serialize().hex, "1976a9141c4bc762dd5423e332166702cb75f40df79fea1288ac")

        let output1 = TransactionOutput(amount: banlance1, scriptPubkey: script1)
        XCTAssertEqual(output1.serialize().hex, "a135ef01000000001976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac")
        
        let output2 = TransactionOutput(amount: balance2, scriptPubkey: script2)
        XCTAssertEqual(output2.serialize().hex, "99c39800000000001976a9141c4bc762dd5423e332166702cb75f40df79fea1288ac")
        let lockTime: UInt32 = 410393
        let transaction = Transaction(version: 1, inputs: [input], outputs: [output1, output2], lockTime: lockTime)
        XCTAssertEqual(transaction.id, "452c629d67e41baec3ac6f04fe744b4b9617f8f859c63b3002f8684e7a4fee03")
    }

    func testTransaction() {
        let scriptSig = Script(hex: "473044022074ddd327544e982d8dd53514406a77a96de47f40c186e58cafd650dd71ea522702204f67c558cc8e771581c5dda630d0dfff60d15e43bf13186669392936ec539d030141047e000cc16c9a4d38cb1572b9dc34c1452626aa170b46150d0e806be1b42517f0832c8a58f543128083ffb8632bae94dd5f3e1e89fad0a17f64ed8bbbb90b5753")!
        let input = TransactionInput(prevTx: Data(hex: "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"), prevIndex: 1, scriptSig: scriptSig, sequence: UInt32(4294967295))
        let scriptPubkey1 = Script(hex: "76a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ac")!
        XCTAssertEqual(scriptPubkey1.address(.BTCtestnet)?.legacy, "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB")
        let scriptPubkey2 = Script(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        XCTAssertEqual(scriptPubkey2.address(.BTCtestnet)?.legacy, "mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
        
    }
    
    func testSignHash() {
        let script = Script(hex: "6b483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a")!
        let input = TransactionInput(prevTx: Data(hex: "d1c789a9c60383bf715f3f6ad9d14b91fe55f3deb369fe5d9280cb1a01793f81"), prevIndex: 0, scriptSig: script, sequence: 0xFFFFFFFE)
        let banlance1: UInt64 = 32454049
        let script1 = Script(hex:"76a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac")!
        let balance2: UInt64 = 10011545
        let script2 = Script(hex:"76a9141c4bc762dd5423e332166702cb75f40df79fea1288ac")!

        let output1 = TransactionOutput(amount: banlance1, scriptPubkey: script1)
        
        let output2 = TransactionOutput(amount: balance2, scriptPubkey: script2)
        let lockTime: UInt32 = 410393
        let transaction = Transaction(version: 1, inputs: [input], outputs: [output1, output2], lockTime: lockTime)
        //OP_DUP OP_HASH160 a802fc56c704ce87c42d7c92eb75e7896bdc41ae OP_EQUALVERIFY OP_CHECKSIG
        let redeemScript = try! Script.p2pkhScript(Data(hex: "a802fc56c704ce87c42d7c92eb75e7896bdc41ae"))
        let signhash = transaction.signHash(0, redeemScript: redeemScript)
        XCTAssertEqual(signhash.hex, "27e0c5994dec7824e56dec6b2fcb342eb7cdb0d0957c2fce9882f715e85d81a6")
    }
    
    func testHash() {
        let script = Script(hex: "6b483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a")!
        let input = TransactionInput(prevTx: Data(hex: "d1c789a9c60383bf715f3f6ad9d14b91fe55f3deb369fe5d9280cb1a01793f81"), prevIndex: 0, scriptSig: script, sequence: 0xFFFFFFFE)
        let banlance1: UInt64 = 32454049
        let script1 = Script(hex:"76a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac")!
        let balance2: UInt64 = 10011545
        let script2 = Script(hex:"76a9141c4bc762dd5423e332166702cb75f40df79fea1288ac")!

        let output1 = TransactionOutput(amount: banlance1, scriptPubkey: script1)
        
        let output2 = TransactionOutput(amount: balance2, scriptPubkey: script2)
        let lockTime: UInt32 = 410393
        let unsignedTx = Transaction(version: 1, inputs: [input], outputs: [output1, output2], lockTime: lockTime)
        
        // sign
        let hashType = BTCSigHashType.ALL
        let utxoToSign = TransactionOutput(amount: UInt64(42505594), scriptPubkey: Script(hex: "76a914a802fc56c704ce87c42d7c92eb75e7896bdc41ae88ac")!)
        let helper = SignatureHash(hashType: hashType)
        let _txHash = helper.createSignatureHash(of: unsignedTx, for: utxoToSign, inputIndex: 0)
        print("txHash:\(_txHash.hex)\n")
        XCTAssertEqual(_txHash.hex, "27e0c5994dec7824e56dec6b2fcb342eb7cdb0d0957c2fce9882f715e85d81a6")
    }

}

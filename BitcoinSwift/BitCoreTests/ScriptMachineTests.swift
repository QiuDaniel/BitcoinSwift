//
//  ScriptMachineTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/1/11.
//

import XCTest
@testable import BitCore

class ScriptMachineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCheck() {
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        let hash = Data(hex: prevTxID)
        let index: UInt32 = 1

        let balance: UInt64 = 169012961
//        let fee: UInt64 = 10000000
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"

        let privateKey = try! PrivateKey<Secp256k1>(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey!.toPublicKey()
        let fromPubKeyHash = Crypto.hash160(fromPublicKey.data)
        
        let toPubkeyHash = Base58Check.decode(toAddress)!.dropFirst()
        
        let subScript = Script(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(prevTx: hash, prevIndex: index, scriptSig: subScript)
        
        let banlance1: UInt64 = 50000000
        let script1 = try! Script.p2pkhScript(toPubkeyHash)
        XCTAssertEqual(script1.data.hex, "76a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ac")
        let balance2: UInt64 = 109012961
        let script2 = try! Script.p2pkhScript(fromPubKeyHash)
        XCTAssertEqual(script2.data.hex, "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")
        let output1 = TransactionOutput(amount: banlance1, scriptPubkey: script1)
        let output2 = TransactionOutput(amount: balance2, scriptPubkey: script2)
        
        let unsignedTx = Transaction(version: 1, inputs: [inputForSign], outputs: [output1, output2], lockTime: 0)
        let utxoToSign = TransactionOutput(amount: balance, scriptPubkey: subScript)
        let txHash = unsignedTx.signHash(0, redeemScript: subScript)
        guard let signature = privateKey?.sign(message: Message(raw: txHash)) else {
            XCTFail("Failed to sign tx")
            return
        }
        XCTAssertEqual(fromPublicKey.pubkeyHash.hex, "2a539adfd7aefcc02e0196b4ccf76aea88a1f470")
        let sigData = Data(hex: signature.der) + Data(BTCSigHashType.ALL.uint8)
        let pubkeyData = fromPublicKey.data
        
        let unlockScript = try! Script()
            .append(sigData)
            .append(pubkeyData)
        
        // signed tx
        
        let txin = TransactionInput(prevTx: hash, prevIndex: index, scriptSig: unlockScript)
        let signedTx = Transaction(version: 1, inputs: [txin], outputs: [output1, output2], lockTime: 0)
        
        // crypto verify
        
        do {
            let result = try ECDSA<Secp256k1>.verify(sigData, tx: signedTx, inputIndex: 0, utxo: utxoToSign, pubKeyData: pubkeyData)
            XCTAssertTrue(result)
        } catch let err {
            XCTFail("Crypt verify failed:\(err)")
        }
        
        do {
            let result = try ScriptMachine.verifyTransaction(signedTx: signedTx, inputIndex: 0, utxo: utxoToSign)
            XCTAssertTrue(result)
        } catch let err {
            XCTFail("Crypt verify failed:\(err)")
        }
    }


}

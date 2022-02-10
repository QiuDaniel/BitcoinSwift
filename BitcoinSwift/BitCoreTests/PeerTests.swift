//
//  PeerTests.swift
//  BitCoreTests
//
//  Created by SPARK-Daniel on 2022/2/9.
//

import XCTest
@testable import BitCore

class SpyDelegate: PeerDelegate {
    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateResult: Any? = nil
    
    // Async test code needs to fulfill the XCTestExpecation used for the test
    // when all the async operations have been completed. For this reason we need
    // to store a reference to the expectation
    var asyncExpectation: XCTestExpectation?
    var fulfilled = false
    
    func peer(_ peer: Peer, didReceiveBlockMessage message: BlockMessage) {
        
    }
    
    func peer(_ peer: Peer, didReceiveGetDataMessage message: GetDataMessage) {
        somethingWithDelegateResult = message
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        print("--qd-test case:\(message)")
        if !fulfilled {
            print("--qd-fullfilled")
            fulfilled = true
            expectation.fulfill()
        }
    }
}

class PeerTests: XCTestCase {

    let spyDelegate = SpyDelegate()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPeer() throws {
        let peer = Peer(host: "mainnet.programmingbitcoin.com", network: .BTCmainnet, verbose: true)
        peer.delegate = spyDelegate
        peer.connect()
        peer.startSync()
        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
        waitForExpectations(timeout: 1000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard self.spyDelegate.somethingWithDelegateResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssert(true)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

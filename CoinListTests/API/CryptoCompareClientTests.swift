//
//  CryptoCompareClientTests.swift
//  CoinListTests
//
//  Created by Vasily Ptitsyn on 17/10/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import XCTest
@testable import CoinList

class CryptoCompareClientTests: XCTestCase {
    var client: CryptoCompareClient!
    
    override func setUp() {
        client = CryptoCompareClient(session: URLSession.shared)
    }
    
    func testFetchesCoinListResponse() {
        let exp = expectation(description: "Received response")
        client.fetchCountList { result in
            exp.fulfill()
            switch result {
            case .success(let cointList):
                XCTAssertEqual(cointList.response, "Success")
            case .failure(let error):
                XCTFail("Error in coin list request: \(error)")
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testCallsBackOnMainQueue() {
        let exp = expectation(description: "Received response")
        client.fetchCountList { result in
            exp.fulfill()
            XCTAssert(Thread.isMainThread, "Expected to be called back on the main queue")
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}

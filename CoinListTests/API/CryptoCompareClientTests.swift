//
//  CryptoCompareClientTests.swift
//  CoinListTests
//
//  Created by Vasily Ptitsyn on 17/10/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import CoinList

class CryptoCompareClientTests: XCTestCase {
    var client: CryptoCompareClient!
    
    override func setUp() {
        client = CryptoCompareClient(session: URLSession.shared)

        OHHTTPStubs.onStubMissing { request in
            XCTFail("Missing stub for \(request)")
        }

        FixtureLoader.stubCoinListResponse()
    }

    override func tearDown() {
        FixtureLoader.reset()
    }
    
    func testFetchesCoinListResponse() {
        let exp = expectation(description: "Received response")
        client.fetchCoinList { result in
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
        client.fetchCoinList { result in
            exp.fulfill()
            XCTAssert(Thread.isMainThread, "Expected to be called back on the main queue")
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCoinListResponseReturnsServerError() {
        FixtureLoader.stubCoinListReturningError()
        
        let exp = expectation(description: "Received response")
        client.fetchCoinList { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail("Should have returned an error")
            case .failure(let error):
                if case ApiError.serverError(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)
                } else {
                    XCTFail("Expected server error, but got: \(error)")
                }

            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCoinListCatchesErrorWithNobody() {
        FixtureLoader.stubCoinListWithData(Data(bytes: [UInt8.max]))
        let exp = expectation(description: "Received response")
        client.fetchCoinList { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail("Received valid response")
            case .failure(let error):
                if case ApiError.responseFormatInvalid(let str) = error {
                    XCTAssertEqual("<nobody>", str)
                } else {
                    XCTFail("Expected ")
                }
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCoinListRetrievesCoins() {
        let exp = expectation(description: "Received response")
        client.fetchCoinList { result in
            exp.fulfill()
            switch result {
            case .success(let coinList):
                XCTAssertGreaterThan(coinList.data.allCoins().count, 1)
                let coin = coinList.data["BTC"]
                XCTAssertNotNil(coin)
                XCTAssertEqual(coin?.symbol, "BTC")
                XCTAssertEqual(coin?.name, "Bitcoin")
            case .failure(let error):
                XCTFail("Error in coin list request: \(error)")
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testConnectionErrorIsReturned() {
        FixtureLoader.stubCoinListWithConnectionError(code: 999)
        let exp = expectation(description: "Received network error")
        client.fetchCoinList { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail("Should have returned an error")
            case .failure(let error):
                switch error {
                case .connectionError(let e):
                    XCTAssertEqual((e as NSError).code, 999)
                default:
                    XCTFail("Expected connection error, but got: \(error)")
                }

            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}

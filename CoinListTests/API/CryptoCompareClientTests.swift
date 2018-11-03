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

extension CryptoCompareClient {
    func fetchCoinListVerifyingResponse(file: StaticString = #file, line: UInt = #line, _ resultBlock: @escaping
        (ApiResult<CoinList>) -> Void) {
        let exp = XCTestExpectation(description: "Received coin list response")
        fetchCoinList { result in
            exp.fulfill()
            resultBlock(result)
        }
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        switch result {
        case .timedOut:
            XCTFail("Timed out waiting for coin list response", file: file, line: line)
        default:
            break
        }
    }
}

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
        client.fetchCoinListVerifyingResponse { result in
            switch result {
            case .success(let cointList):
                XCTAssertEqual(cointList.response, "Success")
            case .failure(let error):
                XCTFail("Error in coin list request: \(error)")
            }
        }
    }
    
    func testCallsBackOnMainQueue() {
        client.fetchCoinListVerifyingResponse { result in
            XCTAssert(Thread.isMainThread, "Expected to be called back on the main queue")
        }
    }

    func testCoinListResponseReturnsServerError() {
        FixtureLoader.stubCoinListReturningError()
        client.fetchCoinListVerifyingResponse { result in
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
    }

    func testCoinListCatchesErrorWithNobody() {
        FixtureLoader.stubCoinListWithData(Data(bytes: [UInt8.max]))
        client.fetchCoinListVerifyingResponse { result in
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
    }

    func testCoinListRetrievesCoins() {
        client.fetchCoinListVerifyingResponse { result in
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
    }

    func testConnectionErrorIsReturned() {
        FixtureLoader.stubCoinListWithConnectionError(code: 999)
        client.fetchCoinListVerifyingResponse { result in
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
    }
}

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
    func testFetchCoinListVerifyingResponse(file: StaticString = #file, line: UInt = #line, _ resultBlock: @escaping
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

    func testFetchCoinListSuccessfully(
        file: StaticString = #file,
        line: UInt = #line,
        coinListBlock: @escaping (CoinList) -> Void) {
        testFetchCoinListVerifyingResponse { result in
            switch result {
            case .success(let coinList):
                XCTAssertEqual(coinList.response, "Success", file: file, line: line)
                coinListBlock(coinList)
            case .failure(let error):
                XCTFail("Error in coin list request: \(error)", file: file, line: line)
            }
        }
    }

    func testFetchCoinListFailure(file: StaticString = #file,
                                  line: UInt = #line,
                                  errorBlock: @escaping (Error) -> Void) {
        testFetchCoinListVerifyingResponse { result in
            switch result {
            case .success(let coinList):
                XCTFail("Expected error, but received success: \(coinList)", file: file, line: line)
            case .failure(let error):
                errorBlock(error)
            }
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

        continueAfterFailure = false
    }

    override func tearDown() {
        FixtureLoader.reset()
    }
    
    func testFetchesCoinListResponse() {
        client.testFetchCoinListSuccessfully { coinList in
            XCTAssertEqual(coinList.baseImageURL, URL(string: "https://www.cryptocompare.com")!)
        }
    }
    
    func testCallsBackOnMainQueue() {
        client.testFetchCoinListVerifyingResponse { result in
            XCTAssert(Thread.isMainThread, "Expected to be called back on the main queue")
        }
    }

    func testCoinListResponseReturnsServerError() {
        FixtureLoader.stubCoinListReturningError()
        client.testFetchCoinListFailure { error in
            if case ApiError.serverError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected server error, but got: \(error)")
            }
        }
    }

    func testCoinListCatchesErrorWithNobody() {
        FixtureLoader.stubCoinListWithData(Data(bytes: [UInt8.max]))
        client.testFetchCoinListFailure { error in
            if case ApiError.responseFormatInvalid(let str) = error {
                XCTAssertEqual("<nobody>", str)
            } else {
                XCTFail("Expected response format error, but got: \(error)")
            }
        }
    }

    func testCoinListRetrievesCoins() {
        client.testFetchCoinListSuccessfully { coinList in
            self.assertContainsCoin(name: "Bitcoin", symbol: "BTC", coinList: coinList)
        }
    }

    private func assertContainsCoin(
        name: String,
        symbol: String,
        coinList: CoinList,
        file: StaticString = #file, line: UInt = #line) {
        XCTAssertGreaterThan(coinList.data.allCoins().count, 1, "Coin list is empty", file: file, line: line)
        let coin = coinList.data[symbol]
        XCTAssertNotNil(coin, "Could not find a coin in the list with symbol", file: file, line: line)
        XCTAssertEqual(coin?.symbol, symbol, "Symbol incorrect", file: file, line: line)
        XCTAssertEqual(coin?.name, name, "Name is incorrect", file: file, line: line)
    }

    func testConnectionErrorIsReturned() {
        FixtureLoader.stubCoinListWithConnectionError(code: 999)
        client.testFetchCoinListFailure { error in
            if case ApiError.connectionError(let e) = error {
                XCTAssertEqual((e as NSError).code, 999)
            } else {
                XCTFail("Expected connection error, but got: \(error)")
            }
        }
    }

}

//
//  CoinListViewControllerTests.swift
//  CoinListTests
//
//  Created by younke on 03/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import Foundation
import XCTest
import OHHTTPStubs
@testable import CoinList

class MockCryptoClient: CryptoCompareClient {
    var fetchCallCount: Int = 0
    var completeWithResult: ApiResult<CoinList>?
    var delay: TimeInterval = 1
    var fetchExpectation: XCTestExpectation?

    init(completingWith result: ApiResult<CoinList>? = nil) {
        completeWithResult = result
        super.init(session: URLSession.shared)
    }

    override func fetchCoinList(completion: @escaping (ApiResult<CoinList>) -> ()) {
        fetchCallCount += 1
        guard let completeWithResult = self.completeWithResult else { return }
        fetchExpectation = XCTestExpectation(description: "coin list retrieved")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion(completeWithResult)
            self.fetchExpectation?.fulfill()
        }
    }

    func verifyFetchCalled(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(fetchCallCount == 1, "fetchCoinList was not called", file: file, line: line)
    }
}

class CoinListViewControllerTests: XCTestCase {
    var viewController: CoinListViewController!

    override func setUp() {
        super.setUp()
        
        OHHTTPStubs.failOnMissingStubs()
        OHHTTPStubs.stubImageRequests()

        viewController = CoinListViewController.makeFromStoryboard()
    }

    func testFetchesCoinsWhenLoaded() {
        let mockClient = MockCryptoClient()
        viewController.cryptoCompareClient = mockClient
        _ = viewController.view
        mockClient.verifyFetchCalled()
    }

    func testShowsLoadingIndicatorWhileFetching() {
        let mockClient = MockCryptoClient(completingWith: .success(emptyCoinList()))
        viewController.cryptoCompareClient = mockClient
        _ = viewController.view
        XCTAssert(viewController.activityIndicator.isAnimating, "indicator is not animating")
    }

    func testLoadingIndicatorHidesAfterFetchCompletes() {
        let coinList = emptyCoinList()
        let mockClient = MockCryptoClient(completingWith: .success(coinList))
        viewController.cryptoCompareClient = mockClient
        _ = viewController.view
        wait(for: [mockClient.fetchExpectation!], timeout: 3.0)
        XCTAssertFalse(viewController.activityIndicator.isAnimating)
    }

    func testReturnsRowsForEachCoin() {
        let coinList = buildCoinList(with: [
            CoinList.Coin(name: "Bitcoin", symbol: "BTC", imagePath: nil),
            CoinList.Coin(name: "Etherium", symbol: "ETH", imagePath: nil),
            ])
        let mockClient = MockCryptoClient(completingWith: .success(coinList))
        viewController.cryptoCompareClient = mockClient
        _ = viewController.view
        wait(for: [mockClient.fetchExpectation!], timeout: 3.0)

        let rowCount = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rowCount, 2, "Invalid row count")
    }

    func testReturnsCoinCells() {
        let coinList = buildCoinList(with: [
            CoinList.Coin(name: "Bitcoin", symbol: "BTC", imagePath: "/media/19633/btc.png"),
            CoinList.Coin(name: "Etherium", symbol: "ETH", imagePath: nil),
            ])
        let mockClient = MockCryptoClient(completingWith: .success(coinList))
        viewController.cryptoCompareClient = mockClient
        _ = viewController.view
        wait(for: [mockClient.fetchExpectation!], timeout: 3.0)

        guard let cell = viewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CoinListCell else {
            XCTFail("Did not return the appropriate cell type")
            return
        }

        XCTAssertEqual(cell.coinNameLabel.text, "Etherium")
        XCTAssertEqual(cell.coinSymbolLabel.text, "ETH")
    }

    func testFailsToDownload() {
        let mockClient = MockCryptoClient(completingWith: .failure(ApiError.requestError))
        viewController.cryptoCompareClient = mockClient
        _ = viewController.view
        wait(for: [mockClient.fetchExpectation!], timeout: 3.0)
        let rowCount = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rowCount, 0, "Invalid row count")
    }

    private func emptyCoinList() -> CoinList {
        return buildCoinList(with: [])
    }

    private func buildCoinList(with coins: [CoinList.Coin]) -> CoinList {
        return CoinList(response: "",
                        message: "",
                        baseImageURL: URL(string: "http://foo.com")!,
                        baseLinkURL: URL(string: "http://foo.com")!,
                        data: CoinList.Data(coins: coins))
    }
}

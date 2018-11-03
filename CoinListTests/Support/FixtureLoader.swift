//
//  FixtureLoader.swift
//  CoinListTests
//
//  Created by younke on 01/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import Foundation
import OHHTTPStubs

class FixtureLoader {
    static func reset() {
        OHHTTPStubs.removeAllStubs()
    }

    static func stubCoinListResponse() {
        stub(condition: isHost("min-api.cryptocompare.com") && isPath("/data/all/coinlist")) { req -> OHHTTPStubsResponse in
            return jsonFixture(with: "coinlist.json")
        }
    }

    static func stubCoinListReturningError() {
        let data = "Server Error".data(using: .utf8)!
        stubCoinListWithData(data, statusCode: 500, headers: nil)
    }

    static func stubCoinListWithConnectionError(code: Int) {
        stub(condition: isHost("min-api.cryptocompare.com") && isPath("/data/all/coinlist")) { req -> OHHTTPStubsResponse in
            let fakeError = NSError(domain: "testDomain", code: code, userInfo: nil)
            return OHHTTPStubsResponse(error: fakeError)
        }
    }

    static func stubCoinListWithData(_ data: Data, statusCode: Int32 = 200, headers: [AnyHashable: Any]? = nil) {
        stub(condition: isHost("min-api.cryptocompare.com") && isPath("/data/all/coinlist")) { req -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: data, statusCode: statusCode, headers: headers)
        }
    }

    private static func jsonFixture(with filename: String) -> OHHTTPStubsResponse {
        let bundle = OHResourceBundle("Fixtures", FixtureLoader.self)!
        let path = OHPathForFileInBundle(filename, bundle)!
        return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
    }
}

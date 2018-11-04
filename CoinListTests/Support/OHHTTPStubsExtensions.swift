//
//  OHHTTPStubsExtensions.swift
//  CoinListTests
//
//  Created by younke on 04/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import OHHTTPStubs

extension OHHTTPStubs {
    static func failOnMissingStubs() {
        OHHTTPStubs.onStubMissing { req in
            fatalError("Missing stub for \(req.url!)")
        }
    }
    
    static func stubImageRequests() {
        OHHTTPStubs.stubRequests(passingTest: pathMatches("\\.(png|jpg)")) { (req) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
    }
}


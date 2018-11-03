//
//  CoinList.swift
//  CoinList
//
//  Created by Vasily Ptitsyn on 17/10/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import Foundation

struct CoinList: Decodable {
    var response: String
    var message: String
    var baseImageURL: URL
    var baseLinkURL: URL
    var data: Data
    
    private enum CodingKeys: String, CodingKey {
        case response = "Response"
        case message = "Message"
        case baseImageURL = "BaseImageUrl"
        case baseLinkURL = "BaseLinkUrl"
        case data = "Data"
    }

    struct Data: Decodable {
        // we got dynamic keys
        private struct Keys: CodingKey {
            var stringValue: String

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            var intValue: Int?

            init?(intValue: Int) {
                self.stringValue = String(intValue)
                self.intValue = intValue
            }
        }

        private var coins: [String: Coin] = [:]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            for key in container.allKeys {
                coins[key.stringValue] = try container.decode(Coin.self, forKey: key)
            }
        }

        init(coins: [Coin]) {
            coins.forEach {
                self.coins[$0.symbol] = $0
            }
        }

        func allCoins() -> [Coin] {
            return Array(coins.values)
        }

        subscript(_ key: String) -> Coin? {
            return coins[key]
        }
    }

    struct Coin: Decodable {
        let name: String
        let symbol: String
        let imagePath: String?

        private enum CodingKeys: String, CodingKey {
            case name = "CoinName"
            case symbol = "Symbol"
            case imagePath = "ImagePath"
        }
    }
}

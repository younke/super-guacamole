//
//  Coin.swift
//  CoinList
//
//  Created by younke on 03/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import Foundation

struct Coin {
    let name: String
    let symbol: String
    let imageURL: URL?

    static func convert(_ coinList: CoinList) -> [Coin] {
        let baseImageURL = coinList.baseImageURL
        return coinList.data.allCoins().map { coinData in
            let imageURL = coinData.imagePath.flatMap { baseImageURL.appendingPathComponent($0) }
            return Coin(name: coinData.name, symbol: coinData.symbol, imageURL: imageURL)
        }
    }
}

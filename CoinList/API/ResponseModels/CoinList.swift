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
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case message = "Message"
    }
}

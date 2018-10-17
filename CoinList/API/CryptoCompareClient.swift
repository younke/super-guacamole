//
//  CryptoCompareClient.swift
//  CoinList
//
//  Created by Vasily Ptitsyn on 17/10/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import Foundation

infix operator -=>

enum ApiResult<T: Decodable> {
    case success(T)
    case failure(ApiError)
}

enum ApiError: Error {
    case notFound // 404
    case serverError // 5xx
    case requestError // 4xx
    case responseFormatInvalid(String)
    case connectionError(Error)
}

typealias ApiCompletionBlock<T: Decodable> = (ApiResult<T>) -> Void

class CryptoCompareClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetchCountList(completion: @escaping ApiCompletionBlock<CoinList>) {
        let url = URL(string: "https://min-api.cryptocompare.com/data/all/coinlist")!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { (data, response, error) in
            if let e = error {
                ApiResult.failure(.connectionError(e)) -=> completion
            } else {
                let http = response as! HTTPURLResponse
                switch http.statusCode {
                case 200:
                    let jsonDecoder = JSONDecoder()
                    do {
                        let coinList = try jsonDecoder.decode(CoinList.self, from: data!)
                        ApiResult.success(coinList) -=> completion
                    } catch let e {
                        print(e)
                        let bodyString = String(data: data!, encoding: .utf8)
                        ApiResult.failure(.responseFormatInvalid(bodyString ?? "<nobody>")) -=> completion
                    }
                default:
                    ApiResult.failure(.serverError) -=> completion
                }
            }
        }
        task.resume()
    }
}

func -=><T>(result: ApiResult<T>, completion: @escaping ApiCompletionBlock<T>) {
    DispatchQueue.main.async {
        completion(result)
    }
}
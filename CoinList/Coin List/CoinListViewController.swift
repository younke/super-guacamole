//
//  CoinListViewController.swift
//  CoinList
//
//  Created by younke on 03/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import UIKit

final class CoinListViewController: UITableViewController, StoryboardInitializable {

    var cryptoCompareClient: CryptoCompareClient = CryptoCompareClient(session: URLSession.shared)

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true

        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // load coins
        activityIndicator.startAnimating()
        cryptoCompareClient.fetchCoinList { _ in
            self.activityIndicator.stopAnimating()
        }
    }
}

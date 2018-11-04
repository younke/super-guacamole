//
//  CoinListViewController.swift
//  CoinList
//
//  Created by younke on 03/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import UIKit
import Kingfisher

final class CoinListViewController: UITableViewController, StoryboardInitializable {

    var cryptoCompareClient: CryptoCompareClient = CryptoCompareClient(session: URLSession.shared)

    private var coins: [Coin]?

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
        cryptoCompareClient.fetchCoinList { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let coinList):
                self.coins = Coin.convert(coinList)
                self.tableView.reloadData()
            case .failure(_):
                fatalError()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CoinListCell.cellReused(from: tableView, for: indexPath)!
        guard let coin = coins?[indexPath.row] else { return cell }
        cell.coinNameLabel.text = coin.name
        cell.coinSymbolLabel.text = coin.symbol
        cell.coinImageView.kf.setImage(with: coin.imageURL)
        return cell
    }
}

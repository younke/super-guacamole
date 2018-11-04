//
//  ReusableCell.swift
//  CoinList
//
//  Created by younke on 04/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import UIKit

protocol ReusableCell where Self: UITableViewCell {
    static var cellIdentifier: String { get }
    static func cellReused(from tableView: UITableView) -> Self?
    static func cellReused(from tableView: UITableView, for indexPath: IndexPath) -> Self?
}

extension ReusableCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
    static func cellReused(from tableView: UITableView) -> Self? {
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? Self
    }
    static func cellReused(from tableView: UITableView, for indexPath: IndexPath) -> Self? {
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Self
    }
}

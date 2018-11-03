//
//  StoryboardInitializable.swift
//  CoinList
//
//  Created by younke on 03/11/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import UIKit

protocol StoryboardInitializable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }

    static func makeFromStoryboard() -> Self

    func embeddedInNavigationController() -> (Self, UINavigationController)
    func embeddedInNavigationController(navBarClass: AnyClass?) -> (Self, UINavigationController)
}

extension StoryboardInitializable where Self : UIViewController {
    static var storyboardName: String {
        return "Main"
    }

    static var storyboardBundle: Bundle? {
        return nil
    }

    static var storyboardIdentifier: String {
        return String(describing: self)
    }

    static func makeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        return storyboard.instantiateViewController(
            withIdentifier: storyboardIdentifier) as! Self
    }

    func embeddedInNavigationController() -> (Self, UINavigationController) {
        return embeddedInNavigationController(navBarClass: nil)
    }

    func embeddedInNavigationController(navBarClass: AnyClass?) -> (Self, UINavigationController) {
        let nav = UINavigationController(navigationBarClass: navBarClass, toolbarClass: nil)
        nav.viewControllers = [self]
        return (self, nav)
    }
}

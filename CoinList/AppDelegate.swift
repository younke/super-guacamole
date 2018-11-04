//
//  AppDelegate.swift
//  CoinList
//
//  Created by Vasily Ptitsyn on 17/10/2018.
//  Copyright © 2018 younke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard !isRunningUnitTests else {
            window = nil
            return true
        }
        return true
    }

    private var isRunningUnitTests: Bool {
        let env = ProcessInfo.processInfo.environment
        print("ENV KEYS: \(env.keys)")
        return env.keys.contains("XCInjectBundleInfo")
    }
}


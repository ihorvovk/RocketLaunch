//
//  AppDelegate.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationController = window!.rootViewController as! UINavigationController
        coordinator = Coordinator(mainNavigationController: navigationController)
        
        return true
    }
    
    // MARK: - Implementation
    
    private var coordinator: Coordinator? = nil
}


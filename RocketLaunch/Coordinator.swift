//
//  Coordinator.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import UIKit
import RealmSwift

class Coordinator {
    
    let realm: Realm
    let launchLibraryManager: LaunchLibraryManager
    
    init(mainNavigationController: UINavigationController) {
        realm = try! Realm()
        launchLibraryManager = LaunchLibraryManager(realm: realm)
        
        guard  let tabBarController = mainNavigationController.topViewController as? UITabBarController else { return }
        
        if let launchListViewController = tabBarController.viewControllers?.first as? LaunchListViewController {
            launchListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
            launchListViewController.reactor = LaunchListViewReactor(realm: realm, launchLibraryManager: launchLibraryManager, loadLimit: 10, filter: nil)
            launchListViewController.delegate = self
        }
        
        if let favoriteLaunchListViewController = tabBarController.viewControllers?.last as? LaunchListViewController {
            favoriteLaunchListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
            favoriteLaunchListViewController.reactor = LaunchListViewReactor(realm: realm, launchLibraryManager: launchLibraryManager, loadLimit: 10, filter: "isFavorite == true")
            favoriteLaunchListViewController.delegate = self
        }
    }
}

extension Coordinator: LaunchListViewControllerDelegate {
    
    func launchListViewController(_ controller: LaunchListViewController, didSelectLaunch launch: RocketLaunch) {
        if let navigationController = UIStoryboard(name: "LaunchInfo", bundle: nil).instantiateInitialViewController() as? UINavigationController, let infoViewController = navigationController.topViewController as? LaunchInfoViewController {
            infoViewController.reactor = LaunchInfoViewReactor(launchLibraryManager: launchLibraryManager, launch: launch)
            controller.present(navigationController, animated: true, completion: nil)
        }
    }
}

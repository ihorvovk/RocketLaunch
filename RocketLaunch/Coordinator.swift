//
//  Coordinator.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import UIKit

class Coordinator {
    
    let launchLibraryManager: LaunchLibraryManager
    
    init(mainNavigationController: UINavigationController) {
        launchLibraryManager = LaunchLibraryManager()
        
        guard  let tabBarController = mainNavigationController.topViewController as? UITabBarController else { return }
        
        if let launchListViewController = tabBarController.viewControllers?.first as? LaunchListViewController {
            launchListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
            launchListViewController.reactor = LaunchListViewReactor(launchLibraryManager: launchLibraryManager, loadLimit: 10)
            launchListViewController.delegate = self
        }
        
        if let favoriteLaunchListViewController = tabBarController.viewControllers?.last as? LaunchListViewController {
            favoriteLaunchListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
            favoriteLaunchListViewController.reactor = FavoriteLaunchListViewReactor(launchLibraryManager: launchLibraryManager, loadLimit: 10)
            favoriteLaunchListViewController.delegate = self
        }
    }
}

extension Coordinator: LaunchListViewControllerDelegate {
    
    func launchListViewController(_ controller: LaunchListViewController, didSelectLaunch launch: RocketLaunch) {
        if let navigationController = UIStoryboard(name: "LaunchInfo", bundle: nil).instantiateInitialViewController() as? UINavigationController, let infoViewController = navigationController.topViewController as? LaunchInfoViewController {
            infoViewController.reactor = LaunchInfoViewReactor(launch: launch)
            controller.present(navigationController, animated: true, completion: nil)
        }
    }
}

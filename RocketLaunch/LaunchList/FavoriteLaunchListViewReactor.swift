//
//  FavoriteLaunchListViewReactor.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/7/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import Foundation
import RxSwift

class FavoriteLaunchListViewReactor: LaunchListViewReactor {
    
    override var launchIDFilter: [Int]? {
        return launchLibraryManager.favorites
    }
}


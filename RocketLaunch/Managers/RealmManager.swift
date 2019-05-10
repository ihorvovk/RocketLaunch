//
//  RealmManager.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/10/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    var realm: Realm { return try! Realm() }
}

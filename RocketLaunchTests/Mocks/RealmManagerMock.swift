//
//  RealmManagerMock.swift
//  RocketLaunchTests
//
//  Created by Ihor Vovk on 5/10/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import Foundation
import RealmSwift

@testable import RocketLaunch

class RealmManagerMock: RealmManager {
    
    override var realm: Realm { return try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "test", encryptionKey: nil, readOnly: false, schemaVersion: 0, migrationBlock: nil, objectTypes: nil)) }
}

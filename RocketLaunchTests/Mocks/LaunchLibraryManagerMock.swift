//
//  LaunchLibraryManagerMock.swift
//  RocketLaunchTests
//
//  Created by Ihor Vovk on 5/8/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import Foundation
import RxSwift

@testable import RocketLaunch

enum LaunchLibraryManagerError: Error {
    case error
}

class LaunchLibraryManagerMock: LaunchLibraryManager {
    
    let rocketLaunchesJSON: [[String: Any]] = [["id": 1698, "name": "Falcon 9 Block 5 | Starlink"], ["id": 1615,"name": "PSLV  | RISAT-2B"], ["id": 1679,"name": "Soyuz 2.1b/Fregat | Glonass-M"], ["id": 1659,"name": "Kuaizhou-1A | Unknown"], ["id": 1661,"name": "Soyuz 2.1a/Fregat | Meridian-M 18"]]
    
    let rocketLaunchDetailsJSON: [[String:  Any]] = [["id": 1698, "name": "Falcon 9 Block 5 | Starlink", "windowstart": "2019-05-16 02:30:00", "windowend": "2019-05-16 04:00:00", "net": "May 16, 2019 02:30:00 UTC", "status": 1, "tbdtime": 0, "vidURLs": ["https://www.spacex.com/webcast"], "tbddate": 0, "probability": -1, "changed": "2019-05-07 20:24:34", "lsp": "121"], ["id": 1615, "name": "PSLV  | RISAT-2B", "windowstart": "2019-05-21 23:30:00", "windowend": "2019-05-21 23:59:00", "net": "May 21, 2019 23:30:00 UTC", "status": 1, "tbdtime": 0, "tbddate": 0, "probability": -1, "changed": "2019-05-07 18:03:10", "lsp": "31"], ["id": 1679, "name": "Soyuz 2.1b/Fregat | Glonass-M", "windowstart": "2019-05-27 00:00:00", "windowend": "2019-05-27 00:00:00", "net": "May 27, 2019 00:00:00 UTC", "status": 2, "tbdtime": 1, "tbddate": 1, "probability": -1, "changed": "2019-04-28 11:46:20", "lsp": "193"], ["id": 1659, "name": "Kuaizhou-1A | Unknown", "windowstart": "2019-05-30 00:00:00", "windowend": "2019-05-30 00:00:00", "net": "May 30, 2019 00:00:00 UTC", "status": 2, "tbdtime": 1, "tbddate": 1, "probability": -1, "changed": "2019-04-18 07:47:45", "lsp": "194"], ["id": 1661, "name": "Soyuz 2.1a/Fregat | Meridian-M 18", "windowstart": "2019-05-30 00:00:00", "windowend": "2019-05-30 00:00:00", "net": "May 30, 2019 00:00:00 UTC", "status": 2, "tbdtime": 1, "tbddate": 1, "probability": -1, "changed": "2019-04-03 09:29:39","lsp": "193"]]
    
    override func reloadAllRocketLaunches() {
        let launches = rocketLaunchesJSON.compactMap { RocketLaunch(JSON: $0) }
        updateLaunches(launches, isFullyLoaded: false, deleteOld: true)
    }
    
    override func loadRocketLaunchDetails(ids: [Int]) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            let launches = self.rocketLaunchDetailsJSON.compactMap { RocketLaunch(JSON: $0) }.filter { ids.contains($0.id) }
            self.updateLaunches(launches, isFullyLoaded: true, deleteOld: false)
            
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}

//
//  LaunchLibraryManager.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import Alamofire
import RxAlamofire
import AlamofireObjectMapper
import RxSwift
import CocoaLumberjackSwift
import RealmSwift

class LaunchLibraryManager {
    
    init(realm: Realm) {
        self.realm = realm
        if realm.objects(RocketLaunch.self).count == 0 {
            reloadAllRocketLaunches()
        }
    }
    
    func reloadAllRocketLaunches() {
        let parameters: [String: Any] = ["mode": "list", "sort": "desc", "fields": "id,name", "limit": 1000000]
        Alamofire.request(URL(string: "https://launchlibrary.net/1.4/launch")!, parameters: parameters).validate().responseArray(keyPath: "launches") { [weak self] (response: DataResponse<[RocketLaunch]>) in
            switch response.result {
            case .success(let result):
                DDLogInfo("Successfully loaded rocket launch ids")
                self?.updateLaunches(result, isFullyLoaded: false, deleteOld: true)
            case .failure(let error):
                DDLogError("Failed to load rocket launch ids - \(error)")
            }
        }
    }
    
    func loadRocketLaunchDetails(ids: [Int]) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            let parameters: [String: Any] = ["mode": "verbose", "id": ids.map { "\($0)" }.joined(separator: ",")]
            Alamofire.request(URL(string: "https://launchlibrary.net/1.4/launch")!, parameters: parameters).validate().responseArray(keyPath: "launches") { [weak self] (response: DataResponse<[RocketLaunch]>) in
                switch response.result {
                case .success(let result):
                    DDLogInfo("Successfully loaded rocket launches")
                    self?.updateLaunches(result, isFullyLoaded: true, deleteOld: false)
                    
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    DDLogError("Failed to load rocket launches - \(error)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: Implementation
    
    let realm: Realm
    
    func updateLaunches(_ launches: [RocketLaunch], isFullyLoaded: Bool, deleteOld: Bool) {
        let favoriteIDs = Array(realm.objects(RocketLaunch.self)).filter { $0.isFavorite }.map { $0.id }
        
        launches.forEach { launch in
            launch.isFavorite = favoriteIDs.contains(launch.id)
            launch.isFullyLoaded = isFullyLoaded
        }
        
        do {
            try realm.write {
                if deleteOld {
                    realm.deleteAll()
                }
                
                realm.add(launches, update: true)
            }
        } catch {
            DDLogError("Failed to write rocket launches to realm")
        }
    }
}

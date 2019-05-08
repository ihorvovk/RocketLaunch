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

class LaunchLibraryManager {
    
    var favorites: [Int] { return favoritesVariable.value }
    var favoritesObservable: Observable<[Int]> { return favoritesVariable.asObservable() }
    
    init() {
        favoritesVariable = Variable<[Int]>(UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? [])
    }
    
    func loadRocketLaunches(offset: Int? = nil, limit: Int? = nil, ids: [Int]? = nil, name: String? = nil) -> Observable<RocketLaunchPage> {
        return Observable.create { observer -> Disposable in
            var parameters: [String : Any] = ["mode": "verbose"]
            if let offset = offset {
                parameters["offset"] = offset
            }
            
            if let limit = limit {
                parameters["limit"] = limit
            }
            
            if let ids = ids {
                parameters["id"] = ids.map { "\($0)" }.joined(separator: ",")
            }
            
            if let name = name {
                parameters["name"] = name
            }
            
            let mapContext = RocketLaunchMapContext(launchLibraryManager: self)
            
            Alamofire.request(URL(string: "https://launchlibrary.net/1.4/launch")!, parameters: parameters).validate().responseObject(context: mapContext) { (response: DataResponse<RocketLaunchPage>) in
                switch response.result {
                case .success(let result):
                    DDLogInfo("Successfully loaded rocket launches")
                    if let offset = offset, let limit = limit {
                        result.page = offset / limit
                    }
                    
                    observer.onNext(result)
                    observer.onCompleted()
                case .failure(let error):
                    DDLogError("Failed to load rocket launches")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func setLaunch(_ launch: RocketLaunch, isFavorite: Bool) {
        guard let id = launch.id else { return }
        
        var favorites = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? []
        if isFavorite && !favorites.contains(where: { $0 == id }) {
            favorites.append(id)
        } else if !isFavorite {
            favorites.removeAll { $0 == id }
        }
        
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
        UserDefaults.standard.synchronize()
        
        favoritesVariable.value = favorites
    }
    
    func isLaunchFavorite(_ launch: RocketLaunch) -> Bool {
        if let id = launch.id {
            return favoritesVariable.value.contains(id)
        } else {
            return false
        }
    }
    
    // MARK: - Implementation
    
    private let favoritesKey = "favorites"
    private let favoritesVariable: Variable<[Int]>
}

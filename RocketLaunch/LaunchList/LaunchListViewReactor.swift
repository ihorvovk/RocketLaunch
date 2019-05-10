//
//  LaunchListViewReactor.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RealmSwift

class LaunchListViewReactor: Reactor {
    
    enum Action {
        case fetchLaunches(indexes: [Int])
        case setLaunch(index: Int, isFavorite: Bool)
        case search(String?)
        case reload
    }
    
    enum Mutation {
        case setLaunch(index: Int, isFavorite: Bool)
        case search(String?)
    }
    
    struct State {
        var launches: Results<RocketLaunch>
        var searchName: String?
    }
    
    let initialState: State
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchLaunches(indexes: let indexes):
            return mutateFetchLaunches(indexes: indexes)
        case .setLaunch(index: let index, isFavorite: let isFavorite):
            return Observable.just(Mutation.setLaunch(index: index, isFavorite: isFavorite))
        case .search(let name):
            return Observable.just(Mutation.search(name))
        case .reload:
            return mutateReload()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .setLaunch(let index, let isFavorite):
            return reduceSetLaunch(index: index, isFavorite: isFavorite, state: state)
        case .search(let name):
            return reduceSearch(name: name, state: state)
        }
    }
    
    init(realm: Realm, launchLibraryManager: LaunchLibraryManager, loadLimit: Int, filter: String?) {
        self.realm = realm
        self.launchLibraryManager = launchLibraryManager
        self.loadLimit = loadLimit
        self.filter = filter
        
        var launches = realm.objects(RocketLaunch.self)
        if let filter = filter {
            launches = launches.filter(filter)
        }
        
        initialState = State(launches: launches, searchName: nil)
    }
    
    // MARK: - Implementation
    
    private let realm: Realm
    private let launchLibraryManager: LaunchLibraryManager
    private let loadLimit: Int
    private let filter: String?
    private var loadingIndexes: Set<Int> = []
    
    private func mutateFetchLaunches(indexes: [Int]) -> Observable<Mutation> {
        guard !loadingIndexes.isSuperset(of: indexes) else { return Observable.empty() }
        
        var indexes = indexes
        if indexes.count < loadLimit, let lastIndex = indexes.last, lastIndex < currentState.launches.count {
            indexes += Array(lastIndex + 1 ..< min(lastIndex + 1 + loadLimit - indexes.count, currentState.launches.count))
        }
        
        let ids: [Int] = indexes.compactMap { index in
            let launch = currentState.launches[index]
            return launch.isFullyLoaded ? nil : launch.id
        }
        
        if ids.count > 0 {
            loadingIndexes.formUnion(indexes)
            return launchLibraryManager.loadRocketLaunchDetails(ids: ids).do(onCompleted: { [weak self] in
                self?.loadingIndexes.subtract(indexes)
            }).flatMap { Observable.empty() }
        } else {
            return Observable.empty()
        }
    }
    
    private func mutateReload() -> Observable<Mutation> {
        launchLibraryManager.reloadAllRocketLaunches()
        return Observable.empty()
    }
    
    private func reduceSetLaunch(index: Int, isFavorite: Bool, state: State) -> State {
        let launch = state.launches[index]
        try? launch.realm?.write {
            launch.isFavorite = isFavorite
        }
    
        return state
    }
    
    private func reduceSearch(name: String?, state: State) -> State {
        var launches = realm.objects(RocketLaunch.self)
        if let filter = filter {
            launches = launches.filter(filter)
        }
        
        if let name = name, name.count >= 3 {
            launches = launches.filter("name CONTAINS '\(name)'")
        }
        
        var result = state
        result.launches = launches
        result.searchName = name
        
        return result
    }
}

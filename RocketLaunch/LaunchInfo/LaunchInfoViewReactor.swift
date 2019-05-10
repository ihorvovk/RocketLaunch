//
//  LaunchInfoViewReactor.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

class LaunchInfoViewReactor: Reactor {
    
    enum Action {
        case toggleFavorite
    }
    
    enum Mutation {
        case setFavorite(Bool)
    }
    
    struct State {
        var infoURL: URL?
        var isFavorite: Bool
    }
    
    let initialState: State
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleFavorite:
            try? launch.realm?.write {
                launch.isFavorite = !currentState.isFavorite
            }
            
            return Observable.just(.setFavorite(launch.isFavorite))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var result = state
        
        switch mutation {
        case .setFavorite(let isFavorite):
            result.isFavorite = isFavorite
        }
        
        return result
    }
    
    init(launchLibraryManager: LaunchLibraryManager, launch: RocketLaunch) {
        self.launchLibraryManager = launchLibraryManager
        self.launch = launch
        
        initialState = State(infoURL: launch.infoURL, isFavorite: launch.isFavorite)
    }
    
    // MARK: - Implementation
    
    private let launchLibraryManager: LaunchLibraryManager
    private let launch: RocketLaunch
}

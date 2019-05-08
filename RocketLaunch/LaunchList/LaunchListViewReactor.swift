//
//  LaunchListViewReactor.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import PagedArray

class LaunchListViewReactor: Reactor {
    
    enum Action {
        case prefetchLaunches(indexPaths: [IndexPath])
        case setLaunch(index: Int, isFavorite: Bool)
        case search(String?)
        case reload
    }
    
    enum Mutation {
        case setLaunchPage(RocketLaunchPage, reset: Bool)
        case setSearchName(String?)
        case refreshLaunches
        case resetLaunches
    }
    
    struct State {
        var launches: PagedArray<RocketLaunch>?
        var searchName: String?
    }
    
    let initialState = State()
    
    var launchIDFilter: [Int]? {
        return nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .prefetchLaunches(indexPaths: let indexPaths):
            return mutateFetchLaunches(indexPaths: indexPaths)
        case .setLaunch(index: let index, isFavorite: let isFavorite):
            return mutateSetLaunch(index: index, isFavorite: isFavorite)
        case .search(let name):
            return mutateSearch(name: name)
        case .reload:
            return mutateReload()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var result = state
        
        switch mutation {
        case .setLaunchPage(let launchPage, let reset):
            return reduceSetLaunchPage(launchPage, reset: reset, state: state)
        case .setSearchName(let name):
            result.searchName = name
        case .refreshLaunches:
            break
        case .resetLaunches:
            result.launches = nil
        }
        
        return result
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let updateFavorites = launchLibraryManager.favoritesObservable.flatMap { [weak self] favorites -> Observable<Mutation> in
            var result = Observable.just(Mutation.refreshLaunches)
            if let `self` = self, self.launchIDFilter != nil {
                result = result.concat(self.mutateReload())
            }
            
            return result
        }
        
        return Observable.merge(mutateFetchLaunches(indexPaths: [IndexPath(row: 0, section: 0)]), updateFavorites, mutation)
    }
    
    init(launchLibraryManager: LaunchLibraryManager, loadLimit: Int) {
        self.launchLibraryManager = launchLibraryManager
        self.loadLimit = loadLimit
    }
    
    // MARK: - Implementation
    
    let launchLibraryManager: LaunchLibraryManager
    private let loadLimit: Int
    private var pagesLoading: Set<Int> = []
    
    private func mutateFetchLaunches(indexPaths: [IndexPath]) -> Observable<Mutation> {
        let pages = Set(indexPaths.map { $0.row / loadLimit }).filter { page -> Bool in
            return currentState.launches?.elements[page] == nil && !pagesLoading.contains(page)
        }
        
        if pages.count > 0 {
            return Observable.merge(pages.map { page in
                pagesLoading.insert(page)
                return launchLibraryManager.loadRocketLaunches(offset: page * loadLimit, limit: loadLimit, ids: launchIDFilter, name: currentState.searchName).do(onCompleted: { [weak self] in
                    self?.pagesLoading.remove(page)
                }).catchError { _ in Observable.empty() }
            }).map { Mutation.setLaunchPage($0, reset: false) }
        } else {
            return Observable.empty()
        }
    }
    
    private func mutateSetLaunch(index: Int, isFavorite: Bool) -> Observable<Mutation> {
        guard let launch = currentState.launches?[index] else { return Observable.empty() }
        
        launchLibraryManager.setLaunch(launch, isFavorite: isFavorite)
        return Observable.empty()
    }
    
    private func mutateSearch(name: String?) -> Observable<Mutation> {
        var searchName: String?
        if let name = name, name.count >= 3 {
            searchName = name
        } else {
            searchName = nil
        }
        
        return Observable.concat(Observable.just(Mutation.setSearchName(name)), launchLibraryManager.loadRocketLaunches(offset: 0, limit: loadLimit, ids: launchIDFilter, name: searchName).flatMap { launchPage -> Observable<Mutation> in
            return Observable.just(Mutation.setLaunchPage(launchPage, reset: true))
        }).catchErrorJustReturn(Mutation.resetLaunches)
    }
    
    private func mutateReload() -> Observable<Mutation> {
        return launchLibraryManager.loadRocketLaunches(offset: 0, limit: loadLimit, ids: launchIDFilter).flatMap { launchPage -> Observable<Mutation> in
            return Observable.just(Mutation.setLaunchPage(launchPage, reset: true))
        }.catchErrorJustReturn(Mutation.resetLaunches)
    }
    
    private func reduceSetLaunchPage(_ launchPage: RocketLaunchPage, reset: Bool, state: State) -> State {
        var result = state
        if result.launches == nil || reset, let total = launchPage.total {
            result.launches = PagedArray(count: total, pageSize: loadLimit)
        }
        
        if let page = launchPage.page, let launches = launchPage.launches {
            result.launches?.set(launches, forPage: page)
        }
        
        return result
    }
}

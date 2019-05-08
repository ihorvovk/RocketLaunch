//
//  LaunchListViewReactorTests.swift
//  LaunchListViewReactorTests
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import XCTest
@testable import RocketLaunch

class LaunchListViewReactorTests: XCTestCase {
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testFetchLaunches() {
        let reactor = LaunchListViewReactor(launchLibraryManager: LaunchLibraryManagerMock(), loadLimit: 2)

        reactor.action.onNext(.fetchLaunches(indexPaths: [IndexPath(row: 0, section: 0)]))
        XCTAssertNotNil(reactor.currentState.launches)
        XCTAssertEqual(reactor.currentState.launches?.count, 3)
        XCTAssertEqual(reactor.currentState.launches?.loadedElements.count, 2)

        reactor.action.onNext(.fetchLaunches(indexPaths: [IndexPath(row: 2, section: 0)]))
        XCTAssertEqual(reactor.currentState.launches?.count, 3)
        XCTAssertEqual(reactor.currentState.launches?.loadedElements.count, 3)
    }

    func testSetLaunchFavorite() {
        let reactor = LaunchListViewReactor(launchLibraryManager: LaunchLibraryManagerMock(), loadLimit: 2)
        reactor.action.onNext(.fetchLaunches(indexPaths: [IndexPath(row: 0, section: 0)]))

        reactor.action.onNext(.setLaunch(index: 1, isFavorite: false))
        XCTAssertEqual(reactor.currentState.launches?[1]?.isFavorite, false)

        reactor.action.onNext(.setLaunch(index: 1, isFavorite: true))
        XCTAssertEqual(reactor.currentState.launches?[1]?.isFavorite, true)
    }
    
    func testSearch() {
        let reactor = LaunchListViewReactor(launchLibraryManager: LaunchLibraryManagerMock(), loadLimit: 2)
        
        reactor.action.onNext(.search("Thor"))
        XCTAssertEqual(reactor.currentState.searchName, "Thor")
        XCTAssertEqual(reactor.currentState.launches?.count, 1)
        XCTAssertEqual(reactor.currentState.launches?[0]?.name, "Thor DM-21 Agena-B | Discoverer 20")
    }
    
    func testReload() {
        let reactor = LaunchListViewReactor(launchLibraryManager: LaunchLibraryManagerMock(), loadLimit: 2)
        
        reactor.action.onNext(.fetchLaunches(indexPaths: [IndexPath(row: 2, section: 0)]))
        XCTAssertEqual(reactor.currentState.launches?.loadedElements.count, 3)
        
        reactor.action.onNext(.reload)
        XCTAssertEqual(reactor.currentState.launches?.loadedElements.count, 2)
    }
}

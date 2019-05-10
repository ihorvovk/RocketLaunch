//
//  LaunchListViewReactorTests.swift
//  LaunchListViewReactorTests
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import XCTest
import RealmSwift

@testable import RocketLaunch

class LaunchListViewReactorTests: XCTestCase {
    
    var reactor: LaunchListViewReactor!
    
    override func setUp() {
        let realmManager = RealmManagerMock()
        reactor = LaunchListViewReactor(launchLibraryManager: LaunchLibraryManagerMock(realmManager: realmManager), realmManager: realmManager, loadLimit: 2, filter: nil)
    }

    override func tearDown() {
    }

    func testFetchLaunches() {
        XCTAssertEqual(reactor.currentState.launches.count, 5)
        XCTAssertEqual(reactor.currentState.launches[0].isFullyLoaded, false)
        
        reactor.action.onNext(.fetchLaunches(indexes: [0]))
        XCTAssertEqual(reactor.currentState.launches.count, 5)
        XCTAssertEqual(reactor.currentState.launches[0].isFullyLoaded, true)
        XCTAssertEqual(reactor.currentState.launches[1].isFullyLoaded, true)
        XCTAssertEqual(reactor.currentState.launches[4].isFullyLoaded, false)

        reactor.action.onNext(.fetchLaunches(indexes: [4]))
        XCTAssertEqual(reactor.currentState.launches[4].isFullyLoaded, true)
    }

    func testSetLaunchFavorite() {
        reactor.action.onNext(.setLaunch(index: 1, isFavorite: false))
        XCTAssertEqual(reactor.currentState.launches[1].isFavorite, false)

        reactor.action.onNext(.setLaunch(index: 1, isFavorite: true))
        XCTAssertEqual(reactor.currentState.launches[1].isFavorite, true)
        
        reactor.action.onNext(.fetchLaunches(indexes: [1]))
        XCTAssertEqual(reactor.currentState.launches[1].isFavorite, true)
        
        reactor.action.onNext(.reload)
        XCTAssertEqual(reactor.currentState.launches[1].isFavorite, true)
    }
    
    func testSearch() {
        reactor.action.onNext(.search("So"))
        XCTAssertEqual(reactor.currentState.launches.count, 5)
        
        reactor.action.onNext(.search("Soyu"))
        XCTAssertEqual(reactor.currentState.launches.count, 2)
        
        reactor.action.onNext(.search("Falc"))
        XCTAssertEqual(reactor.currentState.launches.count, 1)
        XCTAssertEqual(reactor.currentState.launches[0].name, "Falcon 9 Block 5 | Starlink")
    }
    
    func testReload() {
        reactor.action.onNext(.fetchLaunches(indexes: [0]))
        XCTAssertEqual(reactor.currentState.launches[0].isFullyLoaded, true)
        
        reactor.action.onNext(.reload)
        XCTAssertEqual(reactor.currentState.launches[0].isFullyLoaded, false)
    }
}

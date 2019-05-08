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
    
    override func loadRocketLaunches(offset: Int? = nil, limit: Int? = nil, ids: [Int]? = nil, name: String? = nil) -> Observable<RocketLaunchPage> {
        if name == "Thor", let pageThor = RocketLaunchPage(JSON: pageThorJSON, context: RocketLaunchMapContext(launchLibraryManager: self)) {
            pageThor.page = 0
            return Observable.just(pageThor)
        } else if offset == 0, limit == 2, let page0 = RocketLaunchPage(JSON: page1JSON, context: RocketLaunchMapContext(launchLibraryManager: self)) {
            page0.page = 0
            return Observable.just(page0)
        } else if offset == 2, limit == 2, let page1 = RocketLaunchPage(JSON: page2JSON, context: RocketLaunchMapContext(launchLibraryManager: self)) {
            page1.page = 1
            return Observable.just(page1)
        } else {
            return Observable.error(LaunchLibraryManagerError.error)
        }
    }
    
    let page1JSON: [String: Any] = ["launches":[["id":1831,"name":"Molniya 8K78 | Venera-1VA 2","windowstart":"1961-02-12 00:43:46","windowend":"1961-02-12 00:43:46","net":"February 12, 1961 00:43:46 UTC","status":3,"inhold":0,"tbdtime":0,"holdreason":"","failreason":"","tbddate":0,"probability":0,"hashtag":"","changed":"2019-03-23 22:40:18","lsp":"270"],["id":1832,"name":"Scout X-1 | Explorer 9","windowstart":"1961-02-16 13:05:00","windowend":"1961-02-16 13:05:00","net":"February 16, 1961 13:05:00 UTC","status":3,"inhold":0,"tbdtime":0,"holdreason":"","failreason":"","tbddate":0,"probability":0,"hashtag":"","changed":"2019-03-23 22:40:18","lsp":"44"]],"total":3,"offset":0,"count":2]
    
    let page2JSON: [String: Any] = ["launches":[["id":1833,"name":"Thor DM-21 Agena-B | Discoverer 20","windowstart":"1961-02-17 20:25:02","windowend":"1961-02-17 20:25:02","net":"February 17, 1961 20:25:02 UTC","status":3,"inhold":0,"tbdtime":0,"holdreason":"","failreason":"","tbddate":0,"probability":0,"hashtag":"","changed":"2019-03-23 22:40:18","lsp":"161"]],"total":3,"offset":2,"count":1]
    
    let pageThorJSON: [String: Any] = ["launches":[["id":1833,"name":"Thor DM-21 Agena-B | Discoverer 20","windowstart":"1961-02-17 20:25:02","windowend":"1961-02-17 20:25:02","net":"February 17, 1961 20:25:02 UTC","status":3,"inhold":0,"tbdtime":0,"holdreason":"","failreason":"","tbddate":0,"probability":0,"hashtag":"","changed":"2019-03-23 22:40:18","lsp":"161"]],"total":1,"offset":0,"count":1]
}

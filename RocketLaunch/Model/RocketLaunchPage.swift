//
//  RocketLaunchPage.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import ObjectMapper

class RocketLaunchPage: Mappable {
    
    var offset: Int?
    var count: Int?
    var total: Int?
    var launches: [RocketLaunch]?
    
    var page: Int?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        offset <- map["offset"]
        count <- map["count"]
        total <- map["total"]
        launches <- map["launches"]
    }
}

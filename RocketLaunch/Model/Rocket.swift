//
//  Rocket.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import ObjectMapper

class Rocket: Mappable {
    
    var id: Int?
    var name: String?
    var imageURL: String?
    var wikiURL: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        imageURL <- map["imageURL"]
        wikiURL <- map["wikiURL"]
    }
}

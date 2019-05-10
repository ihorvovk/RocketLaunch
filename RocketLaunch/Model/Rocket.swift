//
//  Rocket.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import RealmSwift
import ObjectMapper

final class Rocket: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var imageURL: String?
    @objc dynamic var wikiURL: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Rocket: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        imageURL <- map["imageURL"]
        wikiURL <- map["wikiURL"]
    }
}

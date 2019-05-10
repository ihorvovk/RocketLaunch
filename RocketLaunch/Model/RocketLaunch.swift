//
//  RocketLaunch.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import RealmSwift
import ObjectMapper

final class RocketLaunch: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var net: Date?
    @objc dynamic var windowStart: Date?
    @objc dynamic var windowEnd: Date?
    @objc dynamic var country: String?
    @objc dynamic var status: Int = 0
    @objc dynamic var rocket: Rocket?
    var infoURLs: List<String>?
    
    @objc dynamic var isFullyLoaded = false
    @objc dynamic var isFavorite = false
    
    var statusDescription: String {
        switch status {
        case 1:
            return "Green"
        case 2:
            return "Red"
        case 3:
            return "Success"
        case 4:
            return "Failed"
        default:
            return "\(status)"
        }
    }
    
    var infoURL: URL? {
        if let firstInfoURL = infoURLs?.first {
            return URL(string: firstInfoURL)
        } else if let rocketWikiURL = rocket?.wikiURL {
            return URL(string: rocketWikiURL)
        } else {
            return nil
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["index", "id", "name"]
    }
}

extension RocketLaunch: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss 'UTC'"
        
        let dateFormatterTransform = DateFormatterTransform(dateFormatter: dateFormatter)
        
        id <- map["id"]
        name <- map["name"]
        net <- (map["net"], dateFormatterTransform)
        windowStart <- (map["windowstart"], dateFormatterTransform)
        windowEnd <- (map["windowend"], dateFormatterTransform)
        country <- map["location.countryCode"]
        status <- map["status"]
        rocket <- map["rocket"]
        infoURLs <- map["infoURLs"]
    }
}

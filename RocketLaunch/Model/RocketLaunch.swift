//
//  RocketLaunch.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor vovk. All rights reserved.
//

import ObjectMapper

struct RocketLaunchMapContext: MapContext {
    let launchLibraryManager: LaunchLibraryManager
}

class RocketLaunch: Mappable {
    
    var id: Int?
    var name: String?
    var windowStart: Date?
    var windowEnd: Date?
    var country: String?
    var status: Int?
    var rocket: Rocket?
    var infoURLs: [String]?
    
    var statusDescription: String? {
        if let status = status {
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
        } else {
            return nil
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
    
    var isFavorite: Bool {
        get {
            return launchLibraryManager?.isLaunchFavorite(self) ?? false
        }

        set(newIsFavorite) {
            launchLibraryManager?.setLaunch(self, isFavorite: newIsFavorite)
        }
    }
    
    required init?(map: Map) {
        launchLibraryManager = (map.context as? RocketLaunchMapContext)?.launchLibraryManager
    }
    
    func mapping(map: Map) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss 'UTC'"
        
        let dateFormatterTransform = DateFormatterTransform(dateFormatter: dateFormatter)
        
        id <- map["id"]
        name <- map["name"]
        windowStart <- (map["windowstart"] , dateFormatterTransform)
        windowEnd <- (map["windowend"], dateFormatterTransform)
        country <- map["location.countryCode"]
        status <- map["status"]
        rocket <- map["rocket"]
        infoURLs <- map["infoURLs"]
    }
    
    // MARK: - Implementation
    
    private let launchLibraryManager: LaunchLibraryManager?
}

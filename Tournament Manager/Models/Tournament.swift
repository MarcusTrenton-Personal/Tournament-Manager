//
//  Tournament.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation
import os.log

struct Tournament {
    let name: String
    let createdAt: Date
    let id: UUID
    let enterUrl: URL
    let detailsUrl: URL
    let type: String
    
    let dateFormatter = DateFormatter()
    
    init(id: UUID, name: String, type: String, createdAt: Date, enterUrl: URL, detailsUrl: URL) {
        self.id = id
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.enterUrl = enterUrl
        self.detailsUrl = detailsUrl
    }
    
    init(json: [String: AnyObject]) throws {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        guard let attributes = json["attributes"],
            let createdAtString = attributes["created_at"] as? String,
            let name: String = attributes["name"] as? String,
            let createdAt = dateFormatter.date(from: createdAtString),
            let idString: String = json["id"] as? String,
            let id: UUID = UUID(uuidString: idString),
            let links = json["links"],
            let enterLink: String = links["enter_tournament"] as? String,
            let enterUrl = URL(string: enterLink),
            let detailsLink: String = links["self"] as? String,
            let detailsUrl = URL(string: detailsLink),
            let type:String = json["type"] as? String
        else {
            os_log("Cannot create Tournament due to non-spec json: %@", type: .error, String(describing: json))
            throw TournamentError.MalformedJson
        }
        
        self.name = name
        self.createdAt = createdAt
        self.id = id
        self.enterUrl = enterUrl
        self.detailsUrl = detailsUrl
        self.type = type
    }
}

enum TournamentError: Error {
    case MalformedJson
}

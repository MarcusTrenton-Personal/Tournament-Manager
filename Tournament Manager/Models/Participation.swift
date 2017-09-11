//
//  Participation.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation
import os.log

struct Participation {
    let entryMessage: String?
    let createdAt: Date
    let id: UUID
    let detailsUrl: URL //Dead link. Returns nothing.
    let type: String
    
    let dateFormatter = DateFormatter()
    
    init(json: [String: AnyObject]) throws {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        guard let attributes = json["attributes"],
            let createdAtString = attributes["created_at"] as? String,
            let createdAt = dateFormatter.date(from: createdAtString),
            let idString: String = json["id"] as? String,
            let id: UUID = UUID(uuidString: idString),
            let links = json["links"],
            let detailsLink: String = links["self"] as? String,
            let detailsUrl = URL(string: detailsLink),
            let type:String = json["type"] as? String
        else {
            os_log("Cannot create Participant due to non-spec json: %@", type: .error, String(describing: json))
            throw ParticipationError.MalformedJson
        }
        
        self.createdAt = createdAt
        self.id = id
        self.detailsUrl = detailsUrl
        self.type = type
        
        //The entry_message is not defined in this json spec or any other 
        //but is required in the problem dsecription. So, it's an optional
        //attribute here.
        let entryMessage : String? = attributes["entry_message"] as? String
        self.entryMessage = entryMessage
    }
}

enum ParticipationError: Error {
    case MalformedJson
}

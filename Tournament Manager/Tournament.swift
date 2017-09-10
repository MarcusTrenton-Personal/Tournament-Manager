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
    let name:String
    
    init(name:String) {
        self.name = name
    }
    
    init(json: [String: AnyObject]) throws {
        guard let attributes = json["attributes"],
            let createdAt = attributes["created_at"],
            let entryMessage = attributes["entry_message"],
            let name: String = attributes["name"] as? String
        else {
                os_log("Cannot create Tournament due to non-spec json: %@", type: .error, String(describing: json))
                throw TournamentError.MalformedJson
        }
        
        self.name = name
    }
}

enum TournamentError: Error {
    case MalformedJson
}

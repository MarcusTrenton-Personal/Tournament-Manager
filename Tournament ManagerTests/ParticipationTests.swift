//
//  ParticipationTests.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-11.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import XCTest
@testable import Tournament_Manager

class ParticipationTests: XCTestCase {
    
    func testParseValidJson() {
        guard let json: [String: AnyObject] = JsonLoader.loadFile(fileName: "ValidParticipation", classRef: self)
            else {
                XCTFail("Failed to load json")
                return
        }
        
        do {
            let participationJson: [String: AnyObject] = json["data"] as! [String : AnyObject]
            let _ = try Participation(json: participationJson)
        } catch {
            XCTFail("Failed to contruct Participation")
        }
        
        //Merely constructing a Tournament successfully is enough
    }
    
    func testParseInvalidJson() {
        guard let json: [String: AnyObject] = JsonLoader.loadFile(fileName: "InvalidParticipation", classRef: self)
            else {
                XCTFail("Failed to load json")
                return
        }
        
        do {
            let participationJson: [String: AnyObject] = json["data"] as! [String : AnyObject]
            let _ = try Participation(json: participationJson)
        } catch {
            return //Pass the test
        }
        
        XCTFail("Constructed Participation from invalid json")
    }
}

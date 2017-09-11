//
//  TournamentTests.swift
//  Tournament ManagerTests
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import XCTest
@testable import Tournament_Manager

class TournamentTests: XCTestCase {
    
    func testParseValidJson() {
        guard let json: [String: AnyObject] = JsonLoader.loadFile(fileName: "ValidTournament", classRef: self)
        else {
            XCTFail("Failed to load json")
            return
        }
        
        do {
            let tournamentJson: [String: AnyObject] = json["data"] as! [String : AnyObject]
            let _ = try Tournament(json: tournamentJson)
        } catch {
            XCTFail("Failed to contruct Tournament")
        }
        
        //Merely constructing a Tournament successfully is enough
    }
    
    func testParseInvalidJson() {
        guard let json: [String: AnyObject] = JsonLoader.loadFile(fileName: "InvalidTournament", classRef: self)
            else {
                XCTFail("Failed to load json")
                return
        }
        
        do {
            let tournamentJson: [String: AnyObject] = json["data"] as! [String : AnyObject]
            let _ = try Tournament(json: tournamentJson)
        } catch {
            return //Pass the test
        }
        
        XCTFail("Constructed Tournament from invalid json")
    }
}

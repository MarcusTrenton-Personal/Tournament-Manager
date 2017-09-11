//
//  Tournament_ManagerUITests.swift
//  Tournament ManagerUITests
//
//  Created by Alexander on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import XCTest

class Tournament_ManagerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testParticipate() {
        //That all of these steps can be done and not crash is enough of a test.
        //Login must work, tournaments parsed, and participation done.
        //However this is brittle as it relies on exact text (Silver) returned by the server. 
        //The test would have to be paired with a staging server with fixed results or mock objects triggered on launch.
        let app = XCUIApplication()
        app.tables.staticTexts["Silver"].tap()
        app.buttons["Particiate"].tap()
        app.alerts["Welcome participant"].buttons["Got it"].tap()
    }
    
}

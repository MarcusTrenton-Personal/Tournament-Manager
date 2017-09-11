//
//  Tournament_ManagerUITests.swift
//  Tournament ManagerUITests
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import XCTest

class Tournament_ManagerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("USE_MOCK_SERVER")
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testParticipate() {
        //That all of these steps can be done and not crash is enough of a test.
        //That flow goes through login, selecting a tournament, and participating.
        //A mock server is used for predetermined output.
        let app = XCUIApplication()
        app.tables.staticTexts["Red"].tap()
        app.buttons["Particiate"].tap()
        app.alerts["Welcome participant"].buttons["Got it"].tap()
    }
    
}

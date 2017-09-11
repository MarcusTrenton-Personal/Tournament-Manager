//
//  AppDelegate.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let useMockServer = ProcessInfo.processInfo.arguments.contains("USE_MOCK_SERVER")
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String
        let serverConnection: IServerConnection = useMockServer ?
            MockServerConnection() :
            RestServerConnection(hostname: host!)
        
        //Setup all singletons
        ServerConnectionContainer.initialize(serverConnection: serverConnection)
        
        return true
    }
}


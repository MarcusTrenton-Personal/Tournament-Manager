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
        // Override point for customization after application launch.
        print("Application launched")
        
        //TODO: Login here
        //TODO: Move into a separate file
        //TODO: Move constant to a config file
        let hostname = "https://damp-chamber-22487.herokuapp.com/api/v1"
        
        //TODO: Figure out how to store credential in session.
        //Otherwise, switch to ephemeral and manage auth manually
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let loginUrlString = hostname + "/authentications/tokens"
        let loginUrl = URL(string: loginUrlString)
        var loginRequest = URLRequest(url: loginUrl!)
        loginRequest.httpMethod = "POST"
        
        print("Before login request")
        let loginTask = session.dataTask(with: loginRequest, completionHandler: {
            (dataOption, responseOption, errorOption) -> Void in
            
            if let error = errorOption {
                print("Error: \(error)")
            } else if let httpResponse = responseOption as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 201:
                    print("Login succeeded")
                    if let data = dataOption {
                        print("Data: \(data)")
                    } else {
                        print("Login failed: No login token returned")
                    }
                case 401:
                    print("Login failed: Incorrect credentials.")
                    //TODO: Notify user
                case 404:
                    print("Login failed: Incorrect url or http method.")
                    //TODO: Notify user
                case 500:
                    print("Login failed: Server error.")
                    //TODO: Notify user
                default:
                    print("Unexpected response code of \(httpResponse.statusCode)")
                    let isSuccess = httpResponse.statusCode % 100 == 2
                    if(isSuccess) {
                        //TODO treat as success
                    } else {
                        //TODO treat as failure
                    }
                }
            } else {
                print("Did not get response HTTPURLResponse as expected. Instead received: \(String(describing: responseOption))")
            }
        })
        loginTask.resume()
        print("After login request")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")
    }


}


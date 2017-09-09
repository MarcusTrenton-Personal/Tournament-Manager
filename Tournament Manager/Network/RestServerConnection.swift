//
//  ServerConnection.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation

class RestServerConnection : IServerConnection {
    
    func login() {
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
    }
}


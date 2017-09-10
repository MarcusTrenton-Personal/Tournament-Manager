//
//  ServerConnection.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation
import os.log

class RestServerConnection : IServerConnection {
    
    var authToken: Data? = nil
    
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
                os_log("Login error: %@", type: .error, String(describing: error))
                self.onLoginFailure(resultCode: LoginResult.FailureUnknownError)
            } else if let httpResponse = responseOption as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 201:
                    os_log("Login succeeded", type: .default)
                    self.onLoginDataReturned(dataOption: dataOption)
                case 401:
                    os_log("Login failed 401: Incorrect credentials.", type: .info)
                    self.onLoginFailure(resultCode: LoginResult.FailureWrongCredentials)
                case 404:
                    os_log("Login failed 404: Incorrect url or http method.", type: .error)
                    self.onLoginFailure(resultCode: LoginResult.FailureWrongAddressOrMethod)
                case 500:
                    os_log("Login failed 500: Server error.", type: .info)
                    self.onLoginFailure(resultCode: LoginResult.FailureInteralServerError)
                default:
                    os_log("Unexpected response code of %@", type: .error, String(describing: httpResponse.statusCode))
                    let isSuccess = httpResponse.statusCode % 100 == 2
                    if(isSuccess) {
                        self.onLoginDataReturned(dataOption: dataOption)
                    } else {
                        self.onLoginFailure(resultCode: LoginResult.FailureUnknownError)
                    }
                }
            } else {
                os_log("Did not get response HTTPURLResponse as expected. Instead received: %@", type: .error, String(describing: responseOption))
                self.onLoginFailure(resultCode: LoginResult.FailureUnknownError)
            }
        })
        loginTask.resume()
        print("After login request")
    }
    
    private func onLoginDataReturned(dataOption: Data?) {
        if let data = dataOption {
            print("Data: \(data)")
            authToken = data
            onLoginSuccess()
        } else {
            os_log("Login failed: No login token returned", type: .error)
            onLoginFailure(resultCode: LoginResult.FailureWrongServerResponse)
        }
    }
    
    private func onLoginSuccess() {
        let returnedInfo = loginResultToDictionary(resultCode: LoginResult.Success)
        NotificationCenter.default.post(
            name: Notification.Name.LoginResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func onLoginFailure(resultCode: LoginResult) {
        let returnedInfo = loginResultToDictionary(resultCode: resultCode)
        NotificationCenter.default.post(
            name: Notification.Name.LoginResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func loginResultToDictionary(resultCode: LoginResult) -> [AnyHashable:Any] {
        return [LoginResultKey.resultCode: resultCode]
    }
}


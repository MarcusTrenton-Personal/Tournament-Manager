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
    
    //TODO: Move constant to a config file
    let hostname = "https://damp-chamber-22487.herokuapp.com/api/v1"
    
    //var since adding an authentication token requires a new session
    var session: URLSession
    
    init() {
        //TODO: Figure out how to store credential in session.
        //Otherwise, switch to ephemeral and manage auth manually
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func login() {
        let urlString = hostname + "/authentications/tokens"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: {
            (dataOption, responseOption, errorOption) -> Void in
            
            if let error = errorOption {
                os_log("Login error: %@", type: .error, String(describing: error))
                self.onLoginFailure(resultCode: EndpointResult.FailureUnknownError)
            } else if let httpResponse = responseOption as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 201:
                    os_log("Login succeeded", type: .default)
                    self.onLoginDataReturned(dataOption: dataOption)
                case 401:
                    os_log("Login failed 401: Incorrect credentials.", type: .info)
                    self.onLoginFailure(resultCode: EndpointResult.FailureWrongCredentials)
                case 404:
                    os_log("Login failed 404: Incorrect url or http method.", type: .error)
                    self.onLoginFailure(resultCode: EndpointResult.FailureWrongAddressOrMethod)
                case 500:
                    os_log("Login failed 500: Server error.", type: .info)
                    self.onLoginFailure(resultCode: EndpointResult.FailureInteralServerError)
                default:
                    os_log("Login has unexpected response code of %@", type: .error, String(describing: httpResponse.statusCode))
                    let isSuccess = httpResponse.statusCode % 100 == 2
                    if(isSuccess) {
                        self.onLoginDataReturned(dataOption: dataOption)
                    } else {
                        self.onLoginFailure(resultCode: EndpointResult.FailureUnknownError)
                    }
                }
            } else {
                os_log("Login did not get response HTTPURLResponse as expected. Instead received: %@", type: .error, String(describing: responseOption))
                self.onLoginFailure(resultCode: EndpointResult.FailureUnknownError)
            }
        })
        task.resume()
    }
    
    private func onLoginDataReturned(dataOption: Data?) {
        
        guard let data = dataOption,
            let dataString = String(data: data, encoding: .utf8)
        else {
            os_log("Login failed: No login token returned", type: .error)
            onLoginFailure(resultCode: EndpointResult.FailureWrongServerResponse)
            return
        }
        
        useAuthToken(authToken: dataString)
        onLoginSuccess()
    }
    
    private func useAuthToken(authToken: String) {
        let configuration = session.configuration;
        let newHeaders = addItemToOptionalDictionary(original: configuration.httpAdditionalHeaders, key: "X-Acme-Authentication-Token", value: authToken)
        configuration.httpAdditionalHeaders = newHeaders
        session = URLSession(configuration: configuration)
    }
    
    
    private func addItemToOptionalDictionary(original: [AnyHashable:Any]?, key: AnyHashable, value: Any) -> [AnyHashable: Any] {
        if var dictionary = original {
            dictionary[key] = value
            return dictionary
        } else {
            return [key : value]
        }
    }
    
    private func onLoginSuccess() {
        let returnedInfo = loginResultToDictionary(resultCode: EndpointResult.Success)
        NotificationCenter.default.post(
            name: Notification.Name.LoginResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func onLoginFailure(resultCode: EndpointResult) {
        let returnedInfo = loginResultToDictionary(resultCode: resultCode)
        NotificationCenter.default.post(
            name: Notification.Name.LoginResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func loginResultToDictionary(resultCode: EndpointResult) -> [AnyHashable:Any] {
        return [LoginResultKey.resultCode: resultCode]
    }
    
    func getAllTournaments() {
        let urlString = hostname + "/tournaments"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {
            (dataOption, responseOption, errorOption) -> Void in
            
            if let error = errorOption {
                os_log("GetAllTournaments error: %@", type: .error, String(describing: error))
                self.onGetAllTournamentsFailure(resultCode: EndpointResult.FailureUnknownError)
            } else if let httpResponse = responseOption as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    os_log("GetAllTournaments succeeded", type: .default)
                    self.onGetAllTournamentsDataReturned(dataOption: dataOption)
                case 401:
                    os_log("GetAllTournaments failed 401: Incorrect credentials.", type: .info)
                    self.onGetAllTournamentsFailure(resultCode: EndpointResult.FailureWrongCredentials)
                case 404:
                    os_log("GetAllTournaments failed 404: Incorrect url or http method.", type: .error)
                    self.onGetAllTournamentsFailure(resultCode: EndpointResult.FailureWrongAddressOrMethod)
                case 500:
                    os_log("GetAllTournaments failed 500: Server error.", type: .info)
                    self.onGetAllTournamentsFailure(resultCode: EndpointResult.FailureInteralServerError)
                default:
                    os_log("GetAllTournaments had unexpected response code of %@", type: .error, String(describing: httpResponse.statusCode))
                    let isSuccess = httpResponse.statusCode % 100 == 2
                    if(isSuccess) {
                        self.onGetAllTournamentsDataReturned(dataOption: dataOption)
                    } else {
                        self.onGetAllTournamentsFailure(resultCode: EndpointResult.FailureUnknownError)
                    }
                }
            } else {
                os_log("GetAllTournaments did not get response HTTPURLResponse as expected. Instead received: %@", type: .error, String(describing: responseOption))
                self.onGetAllTournamentsFailure(resultCode: EndpointResult.FailureUnknownError)
            }
        })
        task.resume()
    }
    
    private func onGetAllTournamentsDataReturned(dataOption: Data?) {
        
        guard let data = dataOption,
            let dataString = String(data: data, encoding: .utf8)
            else {
                os_log("GetAllTournaments failed: No data returned", type: .error)
                onGetAllTournamentsFailure(resultCode: EndpointResult.FailureWrongServerResponse)
                return
        }
        
        print("Tournaments: \(dataString)")
        onGetAllTournamentsSuccess()
    }
    
    private func onGetAllTournamentsSuccess() {
        let returnedInfo = getAllTournamentsResultToDictionary(resultCode: EndpointResult.Success)
        NotificationCenter.default.post(
            name: Notification.Name.GetAllTournamentResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func onGetAllTournamentsFailure(resultCode: EndpointResult) {
        let returnedInfo = getAllTournamentsResultToDictionary(resultCode: resultCode)
        NotificationCenter.default.post(
            name: Notification.Name.GetAllTournamentResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func getAllTournamentsResultToDictionary(resultCode: EndpointResult) -> [AnyHashable:Any] {
        return [GetAllTournamentsResultKey.resultCode: resultCode]
    }
}


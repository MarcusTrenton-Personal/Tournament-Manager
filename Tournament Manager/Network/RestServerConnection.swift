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
    
    let hostname: String //= "https://damp-chamber-22487.herokuapp.com/api/v1"
    
    //var since adding an authentication token requires a new session
    var session: URLSession
    
    init(hostname: String) {
        self.hostname = hostname
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
                    let isSuccess = httpResponse.statusCode / 100 == 2
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
                    let isSuccess = httpResponse.statusCode / 100 == 2
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
        do {
            guard let data = dataOption,
                let dataJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                let tournaments = dataJson["data"] as? [[String: AnyObject]]
            else {
                os_log("GetAllTournaments failed: No data returned", type: .error)
                onGetAllTournamentsFailure(resultCode: EndpointResult.FailureWrongServerResponse)
                return
            }
            
            var tournamentModels: [Tournament] = []
            for tournamentJson in tournaments {
                do {
                    let tournament: Tournament = try Tournament(json: tournamentJson)
                    tournamentModels.append(tournament)
                } catch {
                    os_log("GetAllTournaments discarded unparsable tournament: %@", type: .error, String(describing: tournamentJson))
                }
            }
            
            onGetAllTournamentsSuccess(tournaments: tournamentModels)
            
        } catch {
            os_log("GetAllTournaments failed: Invalid JSON returned", type: .error)
            onGetAllTournamentsFailure(resultCode: EndpointResult.FailureWrongServerResponse)
        }
    }
    
    private func onGetAllTournamentsSuccess(tournaments: [Tournament]) {
        let returnedInfo = getAllTournamentsResultToDictionary(resultCode: EndpointResult.Success, tournaments: tournaments)
        NotificationCenter.default.post(
            name: Notification.Name.GetAllTournamentsResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func onGetAllTournamentsFailure(resultCode: EndpointResult) {
        let returnedInfo = getAllTournamentsResultToDictionary(resultCode: resultCode, tournaments: nil)
        NotificationCenter.default.post(
            name: Notification.Name.GetAllTournamentsResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func getAllTournamentsResultToDictionary(resultCode: EndpointResult, tournaments: [Tournament]?) -> [AnyHashable:Any] {
        return [GetAllTournamentsResultKey.resultCode: resultCode,
                GetAllTournamentsResultKey.tournaments: tournaments as Any]
    }
    
    func getTournament(url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {
            (dataOption, responseOption, errorOption) -> Void in
            
            if let error = errorOption {
                os_log("GetTournament error: %@", type: .error, String(describing: error))
                self.onGetTournamentFailure(resultCode: EndpointResult.FailureUnknownError)
            } else if let httpResponse = responseOption as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    os_log("GetTournament succeeded", type: .default)
                    self.onGetTournamentDataReturned(dataOption: dataOption)
                case 401:
                    os_log("GetTournament failed 401: Incorrect credentials.", type: .info)
                    self.onGetTournamentFailure(resultCode: EndpointResult.FailureWrongCredentials)
                case 404:
                    os_log("GetTournament failed 404: Incorrect url or http method.", type: .error)
                    self.onGetTournamentFailure(resultCode: EndpointResult.FailureWrongAddressOrMethod)
                case 500:
                    os_log("GetTournament failed 500: Server error.", type: .info)
                    self.onGetTournamentFailure(resultCode: EndpointResult.FailureInteralServerError)
                default:
                    os_log("GetTournament had unexpected response code of %@", type: .error, String(describing: httpResponse.statusCode))
                    let isSuccess = httpResponse.statusCode / 100 == 2
                    if(isSuccess) {
                        self.onGetTournamentDataReturned(dataOption: dataOption)
                    } else {
                        self.onGetTournamentFailure(resultCode: EndpointResult.FailureUnknownError)
                    }
                }
            } else {
                os_log("GetTournament did not get response HTTPURLResponse as expected. Instead received: %@", type: .error, String(describing: responseOption))
                self.onGetTournamentFailure(resultCode: EndpointResult.FailureUnknownError)
            }
        })
        task.resume()
    }
    
    private func onGetTournamentDataReturned(dataOption: Data?) {
        do {
            guard let data = dataOption,
                let dataJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                let tournamentJson = dataJson["data"] as? [String: AnyObject]
                else {
                    os_log("GetTournament failed: No data returned", type: .error)
                    onGetTournamentFailure(resultCode: EndpointResult.FailureWrongServerResponse)
                    return
            }
            
            do {
                let tournament: Tournament = try Tournament(json: tournamentJson)
                onGetTournamentSuccess(tournament: tournament)
            } catch {
                os_log("GetTournament discarded unparsable tournament: %@", type: .error, String(describing: tournamentJson))
                onGetTournamentFailure(resultCode: EndpointResult.FailureWrongServerResponse)
            }
            
        } catch {
            os_log("GetTournament failed: Invalid JSON returned", type: .error)
            onGetTournamentFailure(resultCode: EndpointResult.FailureWrongServerResponse)
        }
    }
    
    private func onGetTournamentSuccess(tournament: Tournament) {
        let returnedInfo = getTournamentResultToDictionary(resultCode: EndpointResult.Success, tournament: tournament)
        NotificationCenter.default.post(
            name: Notification.Name.GetTournamentResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func onGetTournamentFailure(resultCode: EndpointResult) {
        let returnedInfo = getTournamentResultToDictionary(resultCode: resultCode, tournament: nil)
        NotificationCenter.default.post(
            name: Notification.Name.GetTournamentResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func getTournamentResultToDictionary(resultCode: EndpointResult, tournament: Tournament?) -> [AnyHashable:Any] {
        return [GetTournamentResultKey.resultCode: resultCode,
                GetTournamentResultKey.tournament: tournament as Any]
    }
    
    func participateInTournament(url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: {
            (dataOption, responseOption, errorOption) -> Void in
            
            if let error = errorOption {
                os_log("ParticipateInTournament error: %@", type: .error, String(describing: error))
                self.onParticipateInTournamentFailure(resultCode: EndpointResult.FailureUnknownError)
            } else if let httpResponse = responseOption as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 201:
                    os_log("ParticipateInTournament succeeded", type: .default)
                    self.onParticipateInTournamentDataReturned(dataOption: dataOption)
                case 401:
                    os_log("ParticipateInTournament failed 401: Incorrect credentials.", type: .info)
                    self.onParticipateInTournamentFailure(resultCode: EndpointResult.FailureWrongCredentials)
                case 404:
                    os_log("ParticipateInTournament failed 404: Incorrect url or http method.", type: .error)
                    self.onParticipateInTournamentFailure(resultCode: EndpointResult.FailureWrongAddressOrMethod)
                case 500:
                    os_log("ParticipateInTournament failed 500: Server error.", type: .info)
                    self.onParticipateInTournamentFailure(resultCode: EndpointResult.FailureInteralServerError)
                default:
                    os_log("ParticipateInTournament had unexpected response code of %@", type: .error, String(describing: httpResponse.statusCode))
                    let isSuccess = httpResponse.statusCode / 100 == 2
                    if(isSuccess) {
                        self.onParticipateInTournamentDataReturned(dataOption: dataOption)
                    } else {
                        self.onParticipateInTournamentFailure(resultCode: EndpointResult.FailureUnknownError)
                    }
                }
            } else {
                os_log("ParticipateInTournament did not get response HTTPURLResponse as expected. Instead received: %@", type: .error, String(describing: responseOption))
                self.onGetTournamentFailure(resultCode: EndpointResult.FailureUnknownError)
            }
        })
        task.resume()
    }
    
    private func onParticipateInTournamentDataReturned(dataOption: Data?) {
        do {
            guard let data = dataOption,
                let dataJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                let participationJson = dataJson["data"] as? [String: AnyObject]
                else {
                    os_log("ParticipateInTournament failed: No data returned", type: .error)
                    onParticipateInTournamentFailure(resultCode: EndpointResult.FailureWrongServerResponse)
                    return
            }
            
            do {
                let participation: Participation = try Participation(json: participationJson)
                onParticipateInTournamentSuccess(participation: participation)
            } catch {
                os_log("ParticipateInTournament discarded unparsable participation: %@", type: .error, String(describing: participationJson))
                onParticipateInTournamentFailure(resultCode: EndpointResult.FailureWrongServerResponse)
            }
            
        } catch {
            os_log("ParticipateInTournament failed: Invalid JSON returned", type: .error)
            onGetTournamentFailure(resultCode: EndpointResult.FailureWrongServerResponse)
        }
    }
    
    private func onParticipateInTournamentSuccess(participation: Participation) {
        let returnedInfo = participateInTournamentResultToDictionary(resultCode: EndpointResult.Success, participation: participation)
        NotificationCenter.default.post(
            name: Notification.Name.ParticipateInTournamentResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func onParticipateInTournamentFailure(resultCode: EndpointResult) {
        let returnedInfo = participateInTournamentResultToDictionary(resultCode: resultCode, participation: nil)
        NotificationCenter.default.post(
            name: Notification.Name.ParticipateInTournamentResult,
            object: nil,
            userInfo: returnedInfo
        )
    }
    
    private func participateInTournamentResultToDictionary(resultCode: EndpointResult, participation: Participation?) -> [AnyHashable:Any] {
        return [ParticipateInTournamentResultKey.resultCode: resultCode,
                ParticipateInTournamentResultKey.partipation: participation as Any]
    }

}


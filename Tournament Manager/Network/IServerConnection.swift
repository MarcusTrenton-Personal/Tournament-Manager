//
//  IServerConnection.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation

//None of the methods use callbacks. Instead they use the NotificationCenter.
//This is done so that multiple objects can observe the results.
//Now the (hypothetical) analytics system can passively listen to results without being coupled to many controllers.
protocol IServerConnection {
    
    //Responds with notification ServerNotificationName.loginResult with data:
    //Key LoginResultKey.resultCode with value type EndpointResult
    func login()
    
    //Responds with notification ServerNotificationName.getAllTournamentsResult with data:
    //Key GetAllTournamentsResultKey.resultCode with value type EndpointResult
    //Key GetAllTournamentsResultKey.tournaments with value type [Tournament]?, which is nil if call fails
    func getAllTournaments()
    
    //Responds with notification ServerNotificationName.getTournamentResult with data:
    //Key GetTournamentResultKey.resultCode with value type EndpointResult
    //Key GetTournamentResultKey.tournament with value type Tournament?, which is nil if call fails
    func getTournament(url: URL)
    
    //Responds with notification ServerNotificationName.garticipateInTournamentResult with data:
    //Key ParticipateInTournamentResultKey.resultCode with value type EndpointResult
    //Key ParticipateInTournamentResultKey.participation with value type Participation
    func participateInTournament(url: URL)
}

extension Notification.Name {
    static let LoginResult = Notification.Name(rawValue: "LoginResult")
    static let GetAllTournamentsResult = Notification.Name(rawValue: "GetAllTournamentsResult")
    static let GetTournamentResult = Notification.Name(rawValue: "GetTournamentResult")
    static let ParticipateInTournamentResult = Notification.Name(rawValue: "ParticipateInTournamentResult")
}

enum EndpointResult: Int {
    case Success = 0
    case FailureWrongCredentials = 1
    case FailureWrongAddressOrMethod = 2
    case FailureInteralServerError = 3
    case FailureWrongServerResponse = 4
    case FailureUnknownError = 5
}

class BaseEndointResultKey {
    static let resultCode = "ResultCode"
}

class LoginResultKey: BaseEndointResultKey {
}

class GetAllTournamentsResultKey: BaseEndointResultKey {
    static let tournaments = "Tournaments"
}

class GetTournamentResultKey: BaseEndointResultKey {
    static let tournament = "Tournament"
}

class ParticipateInTournamentResultKey: BaseEndointResultKey {
    static let partipation = "Participation"
}


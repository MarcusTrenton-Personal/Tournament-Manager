//
//  MockServerConnection.swift
//  Tournament Manager
//
//  Created by Alexander on 2017-09-11.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation

//All server requests succeed and return fake data
class MockServerConnection : IServerConnection {
    
    let red: Tournament
    let blue: Tournament
    let tournaments: [Tournament]
    let participation: Participation
    
    init() {
        let fakeUrl: URL = URL(string: "www.fake.com")!
        
        red = Tournament(id: UUID(), name: "Red", type: "Tournament", createdAt: Date(), enterUrl: fakeUrl, detailsUrl: fakeUrl)
        blue = Tournament(id: UUID(), name: "Blue", type: "Tournament", createdAt: Date(), enterUrl: fakeUrl, detailsUrl: fakeUrl)
        tournaments = [red, blue]
        
        participation = Participation(id: UUID(), type: "Participation", entryMessage: "A new challenger has entered", createdAt: Date(), detailsUrl: fakeUrl)
    }
    
    func login() {
        NotificationCenter.default.post(
            name: Notification.Name.LoginResult,
            object: nil,
            userInfo: [LoginResultKey.resultCode: EndpointResult.Success])
    }
    
    func getAllTournaments() {
        NotificationCenter.default.post(
            name: Notification.Name.GetAllTournamentsResult,
            object: nil,
            userInfo: [GetAllTournamentsResultKey.resultCode: EndpointResult.Success,
                       GetAllTournamentsResultKey.tournaments: tournaments])
    }
    
    func getTournament(url: URL) {
        NotificationCenter.default.post(
            name: Notification.Name.GetTournamentResult,
            object: nil,
            userInfo: [GetTournamentResultKey.resultCode: EndpointResult.Success,
                       GetTournamentResultKey.tournament: red])
    }
    
    func participateInTournament(url: URL) {
        NotificationCenter.default.post(
            name: Notification.Name.ParticipateInTournamentResult,
            object: nil,
            userInfo: [ParticipateInTournamentResultKey.resultCode: EndpointResult.Success,
                       ParticipateInTournamentResultKey.partipation: participation])
    }
}

//
//  TournamentDetailController.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-10.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit
import os.log

class TournamentDetailController: UIViewController {
    
    var tournamentUrl: URL = URL(string: "www.fakeurl.com")! //Will be filled by previous controller
    
    var dateFormatter: DateFormatter = DateFormatter()
    var tournament: Tournament?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    @IBAction func participate(sender: UIButton) {
        participateAsync()
    }
    
    @IBAction func decline(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        addObservers()
        getTournamentAsync()
    }
    
    private func addObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.GetTournamentResult,
                       object: nil,
                       queue: nil,
                       using: onGetTournamentResult)
        nc.addObserver(forName: Notification.Name.ParticipateInTournamentResult,
                       object: nil,
                       queue: nil,
                       using: onParticipateInTournamentResult)
    }
    
    private func getTournamentAsync() {
        ServerConnectionContainer.get()?.getTournament(url: tournamentUrl)
    }
    
    private func onGetTournamentResult(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let resultCode = userInfo[GetTournamentResultKey.resultCode] as? EndpointResult
        else {
            os_log("Notification: %@ did not contain EndpointResult in userInfo[%@]", type: .error, String(describing: notification), GetTournamentResultKey.resultCode)
            return
        }
        
        if(resultCode == EndpointResult.Success) {
            if let tournament = userInfo[GetTournamentResultKey.tournament] as? Tournament {
                updateTournamentUi(tournament: tournament)
            } else {
                os_log("Notification %@ did not contain did not contain a Tournament in userInfo[%@]", type: .error, String(describing: notification), GetTournamentResultKey.tournament)
            }
        } else {
            showTournamentErrorUi(resultCode: resultCode)
        }
    }
    
    private func updateTournamentUi(tournament: Tournament) {
        DispatchQueue.main.async {
            self.tournament = tournament
            self.name.text = tournament.name;
            self.message.text = tournament.entryMessage
            self.createdAt.text = self.dateFormatter.string(from: tournament.createdAt)
        }
    }
    
    private func showTournamentErrorUi(resultCode: EndpointResult) {
        Popups.ShowError(controller: self, resultCode: resultCode, onExit: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func participateAsync() {
        if(tournament != nil) {
            ServerConnectionContainer.get()?.participateInTournament(url: (tournament?.enterUrl)!)
        }
    }
    
    private func onParticipateInTournamentResult(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let resultCode = userInfo[ParticipateInTournamentResultKey.resultCode] as? EndpointResult
            else {
                os_log("Notification: %@ did not contain EndpointResult in userInfo[%@]", type: .error, String(describing: notification), ParticipateInTournamentResultKey.resultCode)
                return
        }
        
        if(resultCode == EndpointResult.Success) {
            if let pariticipation = userInfo[ParticipateInTournamentResultKey.partipation] as? Participation {
                showParticipationUi(participation: pariticipation)
            } else {
                os_log("Notification %@ did not contain did not contain a Pariticipation in userInfo[%@]", type: .error, String(describing: notification), ParticipateInTournamentResultKey.partipation)
            }
        } else {
            showParticipationErrorUi(resultCode: resultCode)
        }
    }
    
    private func showParticipationUi(participation: Participation) {
        let alert = UIAlertController(title: "Welcome participant", message: participation.entryMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showParticipationErrorUi(resultCode: EndpointResult) {
        Popups.ShowError(controller: self, resultCode: resultCode)
    }
}


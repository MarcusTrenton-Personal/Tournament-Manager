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
    @IBOutlet weak var date: UILabel!
    
    @IBAction func participate(sender: UIButton) {
        participateAsync()
    }
    
    private func participateAsync() {
        if(tournament != nil) {
            let nc = NotificationCenter.default
            nc.addObserver(forName: Notification.Name.ParticipateInTournamentResult,
                           object: nil,
                           queue: nil,
                           using: onParticipateInTournamentResult)
            ServerConnectionContainer.get()?.participateInTournament(url: (tournament?.enterUrl)!)
        }
    }
    
    private func onParticipateInTournamentResult(notification: Notification) {
        print("Participate notification \(notification)")
    }
    
    @IBAction func decline(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        getTournamentAsync()
    }
    
    private func getTournamentAsync() {
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.GetTournamentResult,
                       object: nil,
                       queue: nil,
                       using: onGetTournamentResult)
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
            showErrorUi(resultCode: resultCode)
        }
    }
    
    private func updateTournamentUi(tournament: Tournament) {
        DispatchQueue.main.async {
            self.tournament = tournament
            self.name.text = tournament.name;
            self.message.text = tournament.entryMessage
            self.date.text = self.dateFormatter.string(from: tournament.date)
        }
    }
    
    private func showErrorUi(resultCode: EndpointResult) {
        //TODO: show error message
        print("Show GetTournament error")
    }
}


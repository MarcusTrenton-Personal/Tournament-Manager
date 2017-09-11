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
    
    var tournamentUrl:URL = URL(string: "www.fakeurl.com")!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    
    @IBAction func participate(sender: UIButton) {
        print("Clicked participate \(sender)")
    }
    
    @IBAction func decline(sender: UIButton) {
        print("Clicked decline \(sender)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("url \(tournamentUrl)")
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.GetTournamentResult,
                       object: nil,
                       queue: nil,
                       using: onGetTournamentResult)
        ServerConnectionContainer.get()?.getTournament(url: tournamentUrl)
    }
    
    private func onGetTournamentResult(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let resultCode = userInfo[GetAllTournamentsResultKey.resultCode] as? EndpointResult
            else {
                os_log("Notification: %@ did not contain %@", type: .error, String(describing: notification), GetAllTournamentsResultKey.resultCode)
                return
        }
        
        if(resultCode == EndpointResult.Success) {
            print("Received tournament detail")
            if let tournament = userInfo[GetTournamentResultKey.tournament] as? Tournament {
                DispatchQueue.main.async {
                    print("showing tournament: \(tournament)")
                    self.name.text = tournament.name;
                    self.message.text = tournament.entryMessage
                }
            }
        } else {
            //TODO: show error message
            print("Show GetTournament error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//
//  ViewController.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit
import os.log

class TournamentController: UIViewController {
    
    var tournaments: [Tournament] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View loaded")
        
        //FIX THIS: Hard-coded construction
        let tournamentsHard: [Tournament] = [
            Tournament(name: "Dota"),
            Tournament(name: "Overwatch")
        ]
        self.tournaments = tournamentsHard
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.GetAllTournamentResult,
                       object: nil,
                       queue: nil,
                       using: onGetAllTournamentsResult)
        ServerConnectionContainer.get()?.getAllTournaments()
    }

    private func onGetAllTournamentsResult(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let resultCode = userInfo[GetAllTournamentsResultKey.resultCode] as? EndpointResult
            else {
                os_log("Notification: %@ did not contain %@", type: .error, String(describing: notification), GetAllTournamentsResultKey.resultCode)
                return
        }
        
        if(resultCode == EndpointResult.Success) {
            print("New tournament data to display")
        } else {
            //TODO: show error message
            print("Show GetAllTournaments error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TournamentController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tournament = tournaments[indexPath.row]
        let cellIdentifier = "TournamentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = tournament.name
        return cell
    }
}

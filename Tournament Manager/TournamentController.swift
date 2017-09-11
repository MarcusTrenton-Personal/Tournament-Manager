//
//  TournamentController.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit
import os.log

class TournamentController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tournaments: [Tournament] = []
    var tableView: UITableView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View loaded")
        //tournaments = []
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.GetAllTournamentsResult,
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
            print("Received new tournaments")
            if let tournaments = userInfo[GetAllTournamentsResultKey.tournaments] as? [Tournament] {
                DispatchQueue.main.async {
                    self.tournaments = tournaments
                    if(self.tableView != nil) {
                        self.tableView!.reloadData()
                        print("reloading tournaments count: \(tournaments.count)")
                    }
                }
            }
        } else {
            //TODO: show error message
            print("Show GetAllTournaments error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView

        return tournaments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tournament = tournaments[indexPath.row]
        let cellIdentifier = "TournamentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = tournament.name
        cell.detailTextLabel?.text = tournament.entryMessage;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        let haveTournamentForRow = index < tournaments.count
        if(haveTournamentForRow) {
            let nextStoryBoard = UIStoryboard(name: "Tournaments", bundle: nil)
            let nextViewController = nextStoryBoard.instantiateViewController(withIdentifier: "TournamentDetails") as! TournamentDetailController
            nextViewController.tournamentUrl = tournaments[index].detailsUrl
            present(nextViewController, animated: true, completion: nil)
        }
    }
}


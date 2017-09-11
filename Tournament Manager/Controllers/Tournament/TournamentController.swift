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
    
    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        getAllTournamentsAsync()
    }
    
    private func addObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.GetAllTournamentsResult,
                       object: nil,
                       queue: nil,
                       using: onGetAllTournamentsResult)
    }
    
    private func getAllTournamentsAsync() {
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
            if let tournaments = userInfo[GetAllTournamentsResultKey.tournaments] as? [Tournament] {
                updateAllTournamentsUi(tournaments: tournaments)
            } else {
                os_log("Notification %@ did not contain did not contain an [Tournament]? in userInfo[%@]", type: .error, String(describing: notification), GetAllTournamentsResultKey.tournaments)
            }
        } else {
            showErrorUi(resultCode: resultCode)
        }
    }
    
    private func showErrorUi(resultCode: EndpointResult) {
        Popups.ShowError(controller: self, resultCode: resultCode, onExit: { _ in
            self.getAllTournamentsAsync()
        })
    }
    
    private func updateAllTournamentsUi(tournaments: [Tournament]) {
        DispatchQueue.main.async {
            //Could sort the tournaments by createdAt date but the result looks worse.
            //Using the order returned by the server Bronze->Silver->Gold is better.
            self.tournaments = tournaments
            self.table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tournaments"
    }
}


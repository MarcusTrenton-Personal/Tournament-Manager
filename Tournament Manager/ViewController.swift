//
//  ViewController.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tournaments: [Tournament] = []
    weak var tableView: UITableView!

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
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tournament = tournaments[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TournamentCell")
        cell.textLabel?.text = tournament.name
        return cell
    }
}

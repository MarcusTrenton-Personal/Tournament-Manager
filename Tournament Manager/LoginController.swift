//
//  LoginController.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-09.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    //Using viewDidAppear instead of viewDidLoad to support changing scenes
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Login viewDidAppear")
        
        ServerConnectionContainer.get()?.login()
        
        loadNextScene()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadNextScene() {
        let nextStoryBoard = UIStoryboard(name: "Tournaments", bundle: nil)
        let nextViewController = nextStoryBoard.instantiateViewController(withIdentifier: "Tournaments") as UIViewController
        present(nextViewController, animated: true, completion: nil)
    }
    
}

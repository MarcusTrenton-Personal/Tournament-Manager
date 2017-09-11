//
//  LoginController.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-09.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit
import os.log

//The Login storyboard is separate for easier future expansion of the login and new user flow
class LoginController: UIViewController {
    
    //Using viewDidAppear instead of viewDidLoad to support changing scenes
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginAsync();
    }
    
    private func loginAsync() {
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name.LoginResult,
                       object: nil,
                       queue: nil,
                       using: onLoginResult)
        ServerConnectionContainer.get()?.login()
    }
    
    private func onLoginResult(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let resultCode = userInfo[LoginResultKey.resultCode] as? EndpointResult
        else {
                os_log("Notification: %@ did not contain %@", type: .error, String(describing: notification), LoginResultKey.resultCode)
                return
        }
        
        if(resultCode == EndpointResult.Success) {
            loadNextScene()
        } else {
            showErrorUi(resultCode: resultCode)
        }
    }
    
    private func showErrorUi(resultCode: EndpointResult) {
        //TODO: show error message
        print("Show login error")
    }
    
    private func loadNextScene() {
        let nextStoryBoard = UIStoryboard(name: "Tournaments", bundle: nil)
        let nextViewController = nextStoryBoard.instantiateViewController(withIdentifier: "Tournaments") as UIViewController
        present(nextViewController, animated: true, completion: nil)
    }
}

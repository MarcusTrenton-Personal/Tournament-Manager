//
//  Popups.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-11.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import UIKit

struct Popups {
    static func ShowError(controller: UIViewController, resultCode: EndpointResult, onExit: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        var errorMessage = ""
        switch resultCode {
        case EndpointResult.FailureInteralServerError:
            errorMessage = "Server error. Please try again."
        case EndpointResult.FailureWrongAddressOrMethod:
            errorMessage = "App error. Please report bug and wait for a patch."
        case EndpointResult.FailureWrongCredentials:
            errorMessage = "Wrong username or password. Restart app to login."
        case EndpointResult.FailureWrongServerResponse:
            errorMessage = "Server response error. Please try again. If problem persists, report a bug."
        default:
            errorMessage = "Unknown error. Please report the bug."
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: onExit))
        controller.present(alert, animated: true, completion: nil)
    }
}

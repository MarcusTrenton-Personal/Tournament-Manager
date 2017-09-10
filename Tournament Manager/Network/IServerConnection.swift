//
//  IServerConnection.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation

//None of the methods use callbacks. Instead they use the NotificationCenter.
//This is done so that multiple objects can observe the results.
//Now the (hypothetical) analytics system can passively listen to results without being coupled to many controllers.
protocol IServerConnection {
    
    //Login to the server. Responds with ServerNotificationName.loginResult with data of key LoginResultKey.resultCode with value type LoginResult
    func login()
}

extension Notification.Name {
    static let LoginResult = Notification.Name(rawValue: "LoginResult")
}

struct LoginResultKey {
    static let resultCode = "ResultCode"
}

enum LoginResult: Int {
    case Success = 0
    case FailureWrongCredentials = 1
    case FailureWrongAddressOrMethod = 2
    case FailureInteralServerError = 3
    case FailureWrongServerResponse = 4
    case FailureUnknownError = 5
}

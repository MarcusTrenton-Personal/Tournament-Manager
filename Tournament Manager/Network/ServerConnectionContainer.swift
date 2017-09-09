//
//  ServerConnectionContainer.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-08.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation

//This class is a work-around to make singletons test-friendly.
//The container is a singleton that can only be set once with the instance.
//That instance could do actual work or it could be a mock object.
final class ServerConnectionContainer {
    
    private init() {}
    
    static func initialize(serverConnection: IServerConnection) {
        if(instance.serverConnection == nil) {
            instance.serverConnection = serverConnection
        } else {
            print("Cannot initialize a singleton twice")
        }
    }
    
    static func get() -> IServerConnection? {
        return instance.serverConnection
    }

    static let instance = ServerConnectionContainer()
    private var serverConnection: IServerConnection? = nil
}

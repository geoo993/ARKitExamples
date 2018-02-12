//
//  RealmObjectServer.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 11/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

import Foundation

enum LexiRealmError : Error, CustomStringConvertible {
    case realmNotConfigured
    case sessionSynchronization

    var description: String {
        switch self {
        case .realmNotConfigured: return "Realm Not Configured"
        case .sessionSynchronization: return "Session synchronization error"
        }
    }
}

public class RealmObjectServer  {
    struct Access {
        static let localIPAddress = "192.168.1.51"
        static let syncHost = "ec2-54-186-186-202.us-west-2.compute.amazonaws.com" // AWS Elastic IP
        static let syncAuthURL = URL(string: "http://\(syncHost):9080")!
        static let locationsTargetsRealm = "locationTargets"
        static let defaultListID = "9FEE2A2B-C95A-492A-AE91-212DB065F426"
        static let serverURL =  URL(string: "realm://\(syncHost):9080/~/\(locationsTargetsRealm)")!
        static let appID = Bundle.main.bundleIdentifier!
        static let username = "ggeoo93@gmail.com"
        static let password = "sophonie91"
    }
}

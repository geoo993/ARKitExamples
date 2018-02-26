//
//  RealmObjectServer.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 11/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

import RealmSwift

public class RealmObjectServer  {
    public struct Access {
        // **** Realm Cloud Users:
        // **** Replace MY_INSTANCE_ADDRESS with the hostname of your cloud instance
        // **** e.g., "mycoolapp.us1.cloud.realm.io"
        // ****
        // ****
        // **** ROS On-Premises Users
        // **** Replace the AUTH_URL and REALM_URL strings with the fully qualified versions of
        // **** address of your ROS server, e.g.: "http://127.0.0.1:9080" and "realm://127.0.0.1:9080"

        static let MY_INSTANCE_ADDRESS = "location-targets-realm.us1a.cloud.realm.io"
        static let localIPAddress = "192.168.1.51"
        //static let syncHost = "ec2-54-186-186-202.us-west-2.compute.amazonaws.com" // AWS Elastic IP
        public static let syncAuthURL = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
        ///URL(string: "http://\(syncHost):9080")!
        static let locationsTargetsRealm = "locationTargets"
        static let defaultListID = "9FEE2A2B-C95A-492A-AE91-212DB065F426"
        public static let realmServerURL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/\(locationsTargetsRealm)")!
            //URL(string: "realms://\(syncHost):9080/~/\(locationsTargetsRealm)")!
        static let appID = Bundle.main.bundleIdentifier!
        static let username = "ggeoo93@gmail.com"
        static let password = "sophonie91"
        public static let credentials = SyncCredentials.usernamePassword(username: username,
                                                                         password: password, register: true)
    }
    
    private static func getConfiguration(user: SyncUser, objectTypes: [Object.Type]?) -> Realm.Configuration {
        let syncURL = RealmObjectServer.Access.realmServerURL
        let syncConfig = SyncConfiguration(user: user, realmURL: syncURL)
        return Realm.Configuration(syncConfiguration: syncConfig, objectTypes: objectTypes)
    }

    public static func setupRealm(with user : SyncUser,
                                  objectTypes: [Object.Type]?,
                                  completion: @escaping (Realm?, Error?) -> Void ) {
        let configuration = getConfiguration(user: user, objectTypes: objectTypes)
        do {
            let realm = try Realm(configuration: configuration)
            completion(realm, nil)
        } catch let error {
            completion(nil, error)
        }

    }

    public static func setupRealm(with nickname: String,
                                  isAdmin: Bool,
                                  objectTypes: [Object.Type]?,
                                  completion: @escaping (Realm?, Error?) -> Void ) {
        let creds = SyncCredentials.nickname(nickname, isAdmin: isAdmin)

        SyncUser.logIn(with: creds, server: RealmObjectServer.Access.syncAuthURL,
                       onCompletion: { (user, err) in
            if let user = user {
                let configuration = getConfiguration(user: user, objectTypes: objectTypes)
                setupDataSource(with: configuration, completion: { (realm, error) in
                    completion(realm, error)
                })

            } else if let error = err {
                //fatalError(error.localizedDescription)
                 completion(nil, error)
            }
        })

    }

    public static func setupRealmDefault(objectTypes: [Object.Type]?,
                                         completion: @escaping (Realm?, Error?) -> Void ) {

        SyncUser.logIn(with: RealmObjectServer.Access.credentials,
                       server: RealmObjectServer.Access.syncAuthURL) { (user, error) in
            if let user = user {
                let configuration = getConfiguration(user: user, objectTypes: objectTypes)
                setupDataSource(with: configuration, completion: { (realm, error) in
                    completion(realm, error)
                })

            } else if let error = error {
                print("error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }

    }

    private static func setupDataSource(with configuration: Realm.Configuration,
                                 completion: @escaping (Realm?, Error?) -> Void) {

        Realm.asyncOpen(configuration: configuration) { realm, error in
            if let realm = realm {
                // Realm successfully opened, with all remote data available
                //let locationTargets = realm.objects(LocationTarget.self)
                completion(realm, nil)

            } else if let error = error {
                // Handle error that occurred while opening or downloading the contents of the Realm
                print("error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }

    }
}


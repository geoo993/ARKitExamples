//
//  WelcomeViewController.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 21/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import RealmSwift
import AppCore

public class WelcomeViewController: UIViewController {

    public static var bundle : Bundle {
        return Bundle(identifier: "com.geo-games.ARWorldNavigationDemo")!
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        title = "Welcome"

        if let _ = SyncUser.current {
            // We have already logged in here!
            self.navigationController?.pushViewController(ItemsViewController(), animated: true)
        } else {
            let alertController = UIAlertController(title: "Login to Realm Cloud", message: "Supply a nice nickname!", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { [unowned self]
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                let creds = SyncCredentials.nickname(textField.text!, isAdmin: true)

                SyncUser.logIn(with: creds, server: RealmObjectServer.Access.syncAuthURL, onCompletion: { [weak self](user, err) in
                    if let _ = user {
                    } else if let error = err {
                        fatalError(error.localizedDescription)
                    }
                })
                //                RealmObjectServer.setupRealm(with: textField.text!,
                //                                             isAdmin: true,
                //                                             objectTypes: [Item.self], completion: { [weak self] (realm, error) in
                //
                //                    self?.navigationController?.pushViewController(ItemsViewController(), animated: true)
                //                })
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = "A Name for your user"
            })
            self.present(alertController, animated: true, completion: nil)
        }

    }

}

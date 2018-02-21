//
//  ARSavedLocationsTableViewController.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//
// https://realm.io/docs/tutorials/realmtasks/

import UIKit
import RealmSwift
import AppCore

public class ARSavedLocationsTableViewController: UITableViewController {

    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Logout", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes, Logout", style: .destructive, handler: {
            alert -> Void in
            SyncUser.current?.logOut()
            self.navigationController?.popViewController(animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func doubleTapped(_ sender : UITapGestureRecognizer) {
        isEditing = !isEditing
    }

    var realm : Realm?
    var notificationToken: NotificationToken?
    var locationTargets: Results<LocationTarget>! {
        get {
            if let realm = realm {
                return realm.objects(LocationTarget.self).sorted(byKeyPath: "tag", ascending: false)
            } else {
                return nil
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        notificationObserver()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken?.invalidate()
    }

    func notificationObserver() {

        notificationToken = locationTargets.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                print("is error", error)
            }
        }
    }


    // MARK: - LocationTarget in Realm DataBase
    func move(locationTarget item: LocationTarget, toIndex: Int) {

    }

    func update(locationTarget item : LocationTarget, with other: LocationTarget) {
        if let realm = realm {
            item.update(to: realm, with: other) { (error) in
                print("item updated")
            }
        }
    }

    // MARK: - Delete all LocationTarget in Realm DataBase
    func deleteAllTodoItems() {
        if let realm = realm {
            do {
                try realm.write {
                    realm.deleteAll()
                }
            } catch {
                print("Error deleting all todo items in Realm \(error)")
            }
        }
    }


    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationTargets.count
    }


    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as? ARSavedLocaionCell else {
            return UITableViewCell()
        }
        let location = locationTargets[indexPath.row]
        cell.setLoaction(with: location)

        return cell
    }

    // Override to support conditional editing of the table view.
    override public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let realm = self.realm {
            let locationTarget = locationTargets[indexPath.row]
            locationTarget.delete(from: realm, completion: { (error) in
                print("item deleted")
            })

            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support conditional rearranging of the table view.
    override public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // Override to support rearranging the table view.
    override public func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        //var locationToMove = locationTargets[fromIndexPath.row]

        //tableData.removeAtIndex(locationToMove.row)
        //tableData.insert(locationToMove, atIndex: toIndexPath.row)
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    

    deinit {
        notificationToken?.invalidate()
        print("AR Locations deinit")
    }
    
}

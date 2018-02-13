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

public class ARSavedLocationsTableViewController: UITableViewController {

    @IBAction func editing(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
    }

    var locationTargets: Results<LocationTarget>! {
        get {
            if let realm = RealmObjectServer.realm {
                return realm.objects(LocationTarget.self)
            } else {
                return nil
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Move a LocationTarget in Realm DataBase
    func move(locationTarget item: LocationTarget, toIndex: Int) {

    }

    func delete(locationTarget item: LocationTarget) {
        item.deleteFromRealm (completion: { (error) in
            print("item deleted")
        })
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "loactionCell", for: indexPath) as? ARSavedLocaionCell else {
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
        if editingStyle == .delete {
            let locationTarget = locationTargets[indexPath.row]
            delete(locationTarget: locationTarget)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override public func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        //var locationToMove = locationTargets[fromIndexPath.row]
        //tableData.removeAtIndex(locationToMove.row)
        //tableData.insert(locationToMove, atIndex: toIndexPath.row)
    }

    // Override to support conditional rearranging of the table view.
    override public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ARDemosViewController.swift
//  ARDemos
//
//  Created by GEORGE QUENTIN on 30/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import ARKit
import Chameleon
import AppCore
import ARDrawingDemo
import ARPlanetsDemo
import WackAJellyFishDemo
import FloorIsLavaDemo
import IKEADemo
import ARMeasuringDemo
import ARPortalDemo
import ARHoopsDemo
import ARShooterDemo
import TossShapesDemo
import ARDiceeDemo
import ARTelevisionDemo
import ARDancingDemo
import ARHomeDemo

private let CellIdentifier = "tableCell"

private struct Option {
    let title: String
    let name: String
    let bundle: Bundle
    let storyBoard : String
}

public class ARDemosViewController: UITableViewController {

    private var options: [Option] = []
    let selectedColor : UIColor = .random
    
    func updateNavBar (with color : UIColor) {
        if let navController = navigationController {
            let constrastColor = ContrastColorOf(color, returnFlat: true)
            // items color
            navController.navigationBar.tintColor = constrastColor
            
            // background color
            navController.navigationBar.barTintColor = color
            
            // text color
            navController.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: constrastColor]
        }
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ARKit Demos"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        self.tableView.separatorStyle = .none
        
        self.options = [
            Option(title:"Plane Detection", 
                   name: "FloorIsLavaViewController", 
                   bundle: FloorIsLavaViewController.bundle, 
                   storyBoard: "FloorIsLava"),
            Option(title:"AR Drawing", 
                   name: "ARDrawingViewController", 
                   bundle: ARDrawingViewController.bundle, 
                   storyBoard: "ARDrawing"),
            Option(title: "AR Solar System", 
                   name: "ARPlanetsViewController", 
                   bundle: ARPlanetsViewController.bundle, 
                   storyBoard: "ARPlanets"),
            Option(title: "Wack A Jelly Fish", 
                   name: "WackAJellyFishViewController", 
                   bundle: WackAJellyFishViewController.bundle, 
                   storyBoard: "WackAJellyFish"),
            Option(title: "IKEA", 
                   name: "IKEAViewController", 
                   bundle: IKEAViewController.bundle, 
                   storyBoard: "IKEA"),
            Option(title: "AR Measuring", 
                   name: "ARMeasuringViewController", 
                   bundle: ARMeasuringViewController.bundle, 
                   storyBoard: "ARMeasuring"),
            Option(title: "AR Portal", 
                   name: "ARPortalViewController", 
                   bundle: ARPortalViewController.bundle, 
                   storyBoard: "ARPortal"),
            Option(title: "AR Hoops", 
                   name: "ARHoopsViewController", 
                   bundle: ARHoopsViewController.bundle, 
                   storyBoard: "ARHoops"),
            Option(title: "AR Throw", 
                   name: "TossShapesViewController", 
                   bundle: TossShapesViewController.bundle, 
                   storyBoard: "TossShapes"),
            Option(title: "AR Shooter", 
                   name: "ARShooterViewController", 
                   bundle: ARShooterViewController.bundle, 
                   storyBoard: "ARShooter"),
            Option(title: "AR Dicee", 
                   name: "ARDiceeViewController", 
                   bundle: ARDiceeViewController.bundle, 
                   storyBoard: "ARDicee"),
            Option(title: "AR Television", 
                   name: "ARTelevisionViewController", 
                   bundle: ARTelevisionViewController.bundle, 
                   storyBoard: "ARTelevision"),
            Option(title: "AR Dancing", 
                   name: "ARDancingViewController", 
                   bundle: ARDancingViewController.bundle, 
                   storyBoard: "ARDancing"),
            Option(title: "AR Home", 
                   name: "ARHomeViewController", 
                   bundle: ARHomeViewController.bundle, 
                   storyBoard: "ARHome")
        ]
        
        updateNavBar(with: selectedColor)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ARConfiguration.isSupported == false {
            let alert = UIAlertController(title: "Device Requirement", 
                                          message: "Sorry, this app only runs on devices that support augmented reality through ARKit.", 
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
 
}



// MARK: - UITableViewDataSource
extension ARDemosViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        
        let numberOfTodoItems = self.options.count
        
        cell.backgroundColor =  selectedColor.darken(byPercentage: 
            (CGFloat(indexPath.row) / CGFloat(numberOfTodoItems)) )
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? .white, returnFlat: true)
        
        cell.textLabel?.text = self.options[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    // MARK: - UITableViewDelegate

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = options[indexPath.row]
        let bundle = option.bundle
        let storyBoard = option.storyBoard
        let storyboard = UIStoryboard(name: storyBoard, bundle: bundle)       
        let vc = storyboard.instantiateViewController(withIdentifier: option.name)
        vc.title = option.title
        navigationController?.pushViewController(vc, animated: true)
       
    }
}

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for app settings.
*/

import UIKit

enum Setting: String {
    case scaleWithPinchGesture
    case dragOnInfinitePlanes
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.dragOnInfinitePlanes.rawValue: true
        ])
    }
}

extension UserDefaults {
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
}

class SettingsViewController: UITableViewController {
        
    // MARK: - UI Elements
    
	@IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
	@IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
        scaleWithPinchGestureSwitch.isOn = defaults.bool(for: .scaleWithPinchGesture)
        dragOnInfinitePlanesSwitch.isOn = defaults.bool(for: .dragOnInfinitePlanes)
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize.height = tableView.contentSize.height
    }
    
    // MARK: - Actions
    
	@IBAction func didChangeSetting(_ sender: UISwitch) {
		let defaults = UserDefaults.standard
		switch sender {
            case scaleWithPinchGestureSwitch:
                defaults.set(sender.isOn, for: .scaleWithPinchGesture)
            case dragOnInfinitePlanesSwitch:
                defaults.set(sender.isOn, for: .dragOnInfinitePlanes)
            default: break
		}
	}
    
}

//
//  ARSavedLocaionCell.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 13/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import AppCore

public class ARSavedLocaionCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!

    private var _location: LocationTarget?
    var location : LocationTarget? {
        return _location
    }

    public func setLocation(with location: LocationTarget) {
        _location = location
        tagLabel.text = location.tag
        addressLabel.text = location.address
        latitudeLabel.text = "\(location.latitude)"
        longitudeLabel.text = "\(location.longitude)"
        altitudeLabel.text = "\(location.altitude)"
    }
}

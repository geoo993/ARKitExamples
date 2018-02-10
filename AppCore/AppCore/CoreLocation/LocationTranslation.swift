//
//  LocationTranslation.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 05/02/2018.
//  Copyright © 2018 Huis. All rights reserved.
//

public struct LocationTranslation {
    public var latitudeTranslation: Double
    public var longitudeTranslation: Double
    public var altitudeTranslation: Double
    public init(latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
        self.altitudeTranslation = altitudeTranslation
    }
}

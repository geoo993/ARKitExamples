//: Playground - noun: a place where people can play

import UIKit


let heightFeet = Measurement(value: 6, unit: UnitLength.feet)

let heightInches = heightFeet.converted(to: UnitLength.inches)
let heightSensible = heightFeet.converted(to: UnitLength.meters)

let heightAUs = heightFeet.converted(to: UnitLength.astronomicalUnits)

// convert degrees to radians
let degrees = Measurement(value: 180, unit: UnitAngle.degrees)
let radians = degrees.converted(to: .radians)

// convert square meters to square centimeters
let squareMeters = Measurement(value: 4, unit: UnitArea.squareMeters)
let squareCentimeters = squareMeters.converted(to: .squareCentimeters)

// convert bushels to imperial teaspoons
let bushels = Measurement(value: 6, unit: UnitVolume.bushels)
let teaspoons = bushels.converted(to: .imperialTeaspoons)


let distance = Measurement(value: 106.4, unit: UnitLength.kilometers)
// → 106.4 km

/*

 A Measurement (which is a value type in Swift) combines a quantity (106.4) with a unit of measure (kilometers). We could define our own units, but Foundation already includes a bunch of the most common physical quantities. There are currently 21 predefined unit types. These are all subclasses of the abstract Dimension class, and their names all begin with Unit…, such as UnitAcceleration, UnitMass, or UnitTemperature. Here, we use UnitLength.

Each unit class provides class properties for the various specific units that can represent measurements of that type, such as .meters, .kilometers, .miles, or .lightyears. To convert our original measurement in kilometers to other units, we can write:

 */
let distanceInMeters = distance.converted(to: .meters)
// → 106400 m
let distanceInMiles = distance.converted(to: .miles)
// → 66.1140591795394 mi
let distanceInFurlongs = distance.converted(to: .furlongs)
// → 528.911158832419 fur

/*
 We can also multiply measurements by scalar values, as well as add and subtract measurements. Unit conversions are handled automatically if necessary:

 */
let doubleDistance = distance * 2
// → 212.8 km
let distance2 = distance + Measurement(value: 5, unit: UnitLength.kilometers)
// → 111.4 km
let distance3 = distance + Measurement(value: 10, unit: UnitLength.miles)
// → 122493.4 m


let earthsEquatorialRadiusLatitudeKiloMeters = Measurement(value: 6378.137, unit: UnitLength.kilometers)
earthsEquatorialRadiusLatitudeKiloMeters.converted(to: .meters)

let earthsPolarRadiusLongitudeKiloMeters = Measurement(value: 6356.752, unit: UnitLength.kilometers)
earthsPolarRadiusLongitudeKiloMeters.converted(to: .meters)


//let earthsRadiusLatitudeMeters = Measurement(value: 6372797.560856, unit: UnitLength.meters)
let earthsDiameterLatitudeMeters = earthsEquatorialRadiusLatitudeKiloMeters.value * 2
let earthsLatitudeCircumference = Double.pi * earthsDiameterLatitudeMeters

//let earthsRadiusLongitudeMeters = Measurement(value: 5602900.0, unit: UnitLength.meters)
let earthsDiameterLongitudeMeters = earthsPolarRadiusLongitudeKiloMeters.value * 2
let earthsLongitudeCircumference = Double.pi * earthsDiameterLongitudeMeters




let earthsEquatorialCircumference = Measurement(value: 40075, unit: UnitLength.kilometers)
earthsEquatorialCircumference.converted(to: .meters)

let earthsMeridionalCircumference = Measurement(value: 40008, unit: UnitLength.kilometers)
earthsEquatorialCircumference.converted(to: .meters)

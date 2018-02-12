//
//  AddressParser.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Contacts
import MapKit

public class AddressParser: NSObject{

    fileprivate var latitude = NSString()
    fileprivate var longitude  = NSString()
    fileprivate var streetName = NSString()
    fileprivate var streetNumber = NSString()
    fileprivate var route = NSString()
    fileprivate var locality = NSString()
    fileprivate var subLocality = NSString()
    fileprivate var formattedAddress = NSString()
    fileprivate var administrativeArea = NSString()
    fileprivate var administrativeAreaCode = NSString()
    fileprivate var subAdministrativeArea = NSString()
    fileprivate var postalCode = NSString()
    fileprivate var country = NSString()
    fileprivate var subThoroughfare = NSString()
    fileprivate var thoroughfare = NSString()
    fileprivate var ISOcountryCode = NSString()
    fileprivate var state = NSString()

    public init(applePlacemark: CLPlacemark) {
        super.init()
        parseAppleLocationData(applePlacemark)
    }

    public init(googleLocation: NSDictionary) {
        super.init()
        parseGoogleLocationData(googleLocation)
    }

    public func getAddressDictionary()-> NSDictionary{

        let addressDict = NSMutableDictionary()

        addressDict.setValue(latitude, forKey: "latitude")
        addressDict.setValue(longitude, forKey: "longitude")
        addressDict.setValue(streetName, forKey: "streetName")
        addressDict.setValue(streetNumber, forKey: "streetNumber")
        addressDict.setValue(locality, forKey: "locality")
        addressDict.setValue(subLocality, forKey: "subLocality")
        addressDict.setValue(administrativeArea, forKey: "administrativeArea")
        addressDict.setValue(postalCode, forKey: "postalCode")
        addressDict.setValue(country, forKey: "country")
        addressDict.setValue(formattedAddress, forKey: "formattedAddress")

        return addressDict
    }

    private func parseAppleLocationData(_ placemark: CLPlacemark){
    
        if let addressLines = placemark.areasOfInterest {
            self.streetName = (placemark.thoroughfare != nil ? placemark.thoroughfare : "")! as NSString
            self.streetNumber = (placemark.subThoroughfare != nil ? placemark.subThoroughfare : "")! as NSString
            self.locality = (placemark.locality != nil ? placemark.locality : "")! as NSString
            self.postalCode = (placemark.postalCode != nil ? placemark.postalCode : "")! as NSString
            self.subLocality = (placemark.subLocality != nil ? placemark.subLocality : "")! as NSString
            self.administrativeArea = (placemark.administrativeArea != nil ? placemark.administrativeArea : "")! as NSString
            self.country = (placemark.country != nil ?  placemark.country : "")! as NSString
            self.longitude = placemark.location!.coordinate.longitude.description as NSString;
            self.latitude = placemark.location!.coordinate.latitude.description as NSString
            self.ISOcountryCode = (placemark.isoCountryCode != nil ?  placemark.isoCountryCode : "")! as NSString

            let address = CNMutablePostalAddress()
            address.street = self.streetName as String
            address.city = self.locality as String
            address.country = self.country as String
            address.postalCode = self.postalCode as String
            address.isoCountryCode = self.ISOcountryCode as String
            address.subLocality = self.subLocality as String
            address.subAdministrativeArea = self.administrativeArea as String
            address.state = ""
            if(addressLines.count > 0) {
                self.formattedAddress = CNPostalAddressFormatter.string(from: address, style: .mailingAddress) as NSString
            }else{
                self.formattedAddress = ""
            }
        }

    }

    private func parseGoogleLocationData(_ resultDict: NSDictionary){

        let locationDict = (resultDict.value(forKey: "results") as! NSArray).firstObject as! NSDictionary

        let formattedAddrs = locationDict.object(forKey: "formatted_address") as! NSString

        let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
        let location = geometry.object(forKey: "location") as! NSDictionary
        let lat = location.object(forKey: "lat") as! Double
        let lng = location.object(forKey: "lng") as! Double

        self.latitude = lat.description as NSString
        self.longitude = lng.description as NSString

        let addressComponents = locationDict.object(forKey: "address_components") as! NSArray

        self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
        self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
        self.streetName = self.thoroughfare
        self.streetNumber = self.subThoroughfare
        self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
        self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
        self.route = component("route", inArray: addressComponents, ofType: "long_name")
        self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
        self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
        self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
        self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
        self.country =  component("country", inArray: addressComponents, ofType: "long_name")
        self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
        self.formattedAddress = formattedAddrs;

    }

    private func component(_ component:NSString,inArray:NSArray,ofType:NSString) -> NSString{
        let index = inArray.indexOfObject(passingTest:) {obj, idx, stop in

            let objDict:NSDictionary = obj as! NSDictionary
            let types:NSArray = objDict.object(forKey: "types") as! NSArray
            let type = types.firstObject as! NSString
            return type.isEqual(to: component as String)
        }

        if (index == NSNotFound){

            return ""
        }

        if (index >= inArray.count){
            return ""
        }

        let type = ((inArray.object(at: index) as! NSDictionary).value(forKey: ofType as String)!) as! NSString

        if (type.length > 0){

            return type
        }
        return ""

    }

    public func getPlacemark() -> CLPlacemark{

        var addressDict = [String : AnyObject]()

        let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as Array

        let kSubAdministrativeArea = "SubAdministrativeArea"
        let kSubLocality           = "SubLocality"
        let kState                 = "State"
        let kStreet                = "Street"
        let kThoroughfare          = "Thoroughfare"
        let kFormattedAddressLines = "FormattedAddressLines"
        let kSubThoroughfare       = "SubThoroughfare"
        let kPostCodeExtension     = "PostCodeExtension"
        let kCity                  = "City"
        let kZIP                   = "ZIP"
        let kCountry               = "Country"
        let kCountryCode           = "CountryCode"

        addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
        addressDict[kSubLocality] = self.subLocality as NSString
        addressDict[kState] = self.administrativeAreaCode

        addressDict[kStreet] = formattedAddressArray.first! as NSString
        addressDict[kThoroughfare] = self.thoroughfare
        addressDict[kFormattedAddressLines] = formattedAddressArray as AnyObject?
        addressDict[kSubThoroughfare] = self.subThoroughfare
        addressDict[kPostCodeExtension] = "" as AnyObject?
        addressDict[kCity] = self.locality

        addressDict[kZIP] = self.postalCode
        addressDict[kCountry] = self.country
        addressDict[kCountryCode] = self.ISOcountryCode

        let lat = self.latitude.doubleValue
        let lng = self.longitude.doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict as [String : AnyObject]?)

        return (placemark as CLPlacemark)
    }

}


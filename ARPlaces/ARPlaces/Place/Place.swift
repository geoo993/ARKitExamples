
import Foundation
import CoreLocation
import HDAugmentedReality

public let apiURL = "https://maps.googleapis.com/maps/api/place/"
public let apiKey = "AIzaSyABIVczL_qw5mJU5KhNNRSsGASW68JXfag"

public class Place: ARAnnotation {
    let reference: String
    let placeName: String
    let address: String
    var phoneNumber: String?
    var website: String?
    var imageURL: String?
    var infoText: String {
        get {
            var info = "Address: \(address)"
            
            if phoneNumber != nil {
                info += "\nPhone: \(phoneNumber!)"
            }
            
            if website != nil {
                info += "\nweb: \(website!)"
            }
            return info
        }
    }
    
    public init?(location: CLLocation, reference: String, name: String, address: String) {
        self.placeName = name
        self.reference = reference
        self.address = address
        super.init(identifier: reference, title: name, location: location)
        
        //super.init()
        //self.location = location
    }
    
    override public var description: String {
        return placeName
    }
}

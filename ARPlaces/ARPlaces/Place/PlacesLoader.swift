
import Foundation
import SwiftyJSON
import CoreLocation

struct PlacesLoader {
    
    func loadPOIS(location: CLLocation, radius: Int = 30, handler: @escaping (JSON?, NSError?) -> Void) {
        print("Load pois")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let uri = apiURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&sensor=true&types=establishment&key=\(apiKey)"
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(data!)
                    
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        let responseJSON : JSON = JSON(responseObject)
                        handler(responseJSON, nil)
                        
                    } catch let error as NSError {
                        handler(nil, error)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func loadDetailInformation(forPlace: Place, handler: @escaping (JSON?, NSError?) -> Void) {
        
        let uri = apiURL + "details/json?reference=\(forPlace.reference)&sensor=true&key=\(apiKey)"
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(data!)
                    
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        let responseJSON : JSON = JSON(responseObject)
                        handler(responseJSON, nil)
                        
                    } catch let error as NSError {
                        handler(nil, error)
                    }
                }
            }
        }
        
        dataTask.resume()
        
    }
}

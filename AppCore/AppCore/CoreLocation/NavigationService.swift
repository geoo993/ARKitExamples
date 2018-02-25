//
//  NavigationService.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 24/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MapKit
import CoreLocation

public struct NavigationService {

    public static func getDirections(from sourceLocation: CLLocationCoordinate2D,
                                     to destinationLocation: CLLocationCoordinate2D,
                                     request: MKDirectionsRequest,
                                     transportType: MKDirectionsTransportType,
                                     completion: @escaping (MKRoute, [MKRouteStep]) -> Void) {
        var steps: [MKRouteStep] = []

        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        request.source = MKMapItem(placemark: sourcePlaceMark) // MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: destinationPlaceMark)
        request.requestsAlternateRoutes = false
        request.transportType = transportType

        let directions = MKDirections(request: request)

        directions.calculate { response, error in
            
            if let error = error {
                print("Error calculating directions:\(error)")
            } else {
                guard let response = response, let route = response.routes.first else { return }
                for route in response.routes {
                    let step = route.steps
                    steps.append(contentsOf: step)

                    //print(route.name)
                    // Broadway
                    //print(route.advisoryNotices)
                    // []
                    //print(route.expectedTravelTime)
                    // 2500.0

                    //print(step[0].distance)
                    // 1.0
                    //print(step[0].instructions)
                    // Proceed to 7th Ave
                }
                completion(route, steps)
            }
        }
    }
}

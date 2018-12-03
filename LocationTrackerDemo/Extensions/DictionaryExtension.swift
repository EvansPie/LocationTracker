//
//  DictionaryExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

extension Dictionary where Key == String, Value == Any {
    
    var location: CLLocation? {
        guard let coordinateJSON = self["coordinate"] as? [String: Any], let latitude = coordinateJSON["latitude"] as? Double, let longitude = coordinateJSON["longitude"] as? Double else { return nil }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if let horizontalAccuracy = self["horizontalAccuracy"] as? Double,
            let verticalAccuracy = self["verticalAccuracy"] as? Double,
            let speed = self["speed"] as? Double,
            let course = self["course"] as? Double,
            let altitude = self["altitude"] as? Double,
            let timestampStr = self["timestamp"] as? String,
            let timestamp = timestampStr.toDate() {
            return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)
        } else {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
}

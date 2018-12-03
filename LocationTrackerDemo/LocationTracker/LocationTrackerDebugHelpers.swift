//
//  LocationTrackerDebugHelpers.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/2/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

extension LocationTracker {
    
    func generateDebugLocationsJSON(locations: [[CLLocation]]) -> URL? {
        let locationsJSONArray = locations.compactMap({ $0.compactMap({ $0.JSONRepresentation }) })
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationsJSONArray, options: .prettyPrinted)
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("locations.json")
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func generateGPX(locations: [CLLocation]) -> URL? {
        if locations.count == 0 { return nil }
        let sortedLocations = locations.sorted(by: { $0.timestamp < $1.timestamp })
        
        var str = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\" creator=\"evangelospittas@gmail.com\" version=\"1.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\">\n"
        
        for (i, location) in sortedLocations.enumerated() {
            let obj =
                "<wpt lat=\"\(location.coordinate.latitude)\" lon=\"\(location.coordinate.longitude)\">\n" +
                "   <name>WP\(String(format: "%03d", i))</name>\n" +
                "   <speed>\(location.speed)</speed>\n" +
                "   <ele>\(location.altitude)</ele>\n" +
                "   <time>\(location.timestamp.toString())</time>\n" +
                "</wpt>\n"
            str += obj
        }
        
        str += "\n</gpx>"
        let data = str.data(using: .utf8)
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("route.gpx")
            try data?.write(to: fileURL)
            return fileURL
        } catch {
            print(error)
        }

        return nil
    }
    
}

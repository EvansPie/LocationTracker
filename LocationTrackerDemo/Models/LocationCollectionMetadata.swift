//
//  LocationCollectionMetadata.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

struct LocationCollectionMetadata {
    let locations: [CLLocation]
    
    
    var distanceCovered: CLLocationDistance?
    var totalDuration: TimeInterval?
    
    var avgSpeedBasedOnLocationUpdates: CLLocationSpeed?
    var avgSpeedBasedOnSpeedProperties: CLLocationSpeed?
    var avgWindowSpeedBasedOnLocationUpdates: CLLocationSpeed?
    var avgWindowSpeedBasedOnSpeedProperties: CLLocationSpeed?
    var currentSpeedBasedOnLocationUpdates: CLLocationSpeed?
    var currentSpeedBasedOnSpeedProperties: CLLocationSpeed?
    
    var avgPaceBasedOnLocationUpdates: CLLocationSpeed? { return avgSpeedBasedOnLocationUpdates?.toPace() }
    var avgPaceBasedOnSpeedProperties: CLLocationSpeed? { return avgSpeedBasedOnSpeedProperties?.toPace() }
    var avgWindowPaceBasedOnLocationUpdates: CLLocationSpeed? { return avgWindowSpeedBasedOnLocationUpdates?.toPace() }
    var avgWindowPaceBasedOnSpeedProperties: CLLocationSpeed? { return avgWindowSpeedBasedOnSpeedProperties?.toPace() }
    var currentPaceBasedOnLocationUpdates: CLLocationSpeed? { return currentSpeedBasedOnLocationUpdates?.toPace() }
    var currentPaceBasedOnSpeedProperties: CLLocationSpeed? { return currentSpeedBasedOnSpeedProperties?.toPace() }

    init(locations _locations: [CLLocation], timeWindow: TimeInterval? = nil, distanceWindow: CLLocationDistance? = nil) {
        // Newest location is first in the array. This helps us to apply the distance window filter.
        locations = _locations.sorted(by: { $0.timestamp > $1.timestamp })
        
        if locations.count < 1 {
            distanceCovered = nil
            totalDuration = nil
            avgSpeedBasedOnLocationUpdates = nil
            avgSpeedBasedOnSpeedProperties = nil
            avgWindowSpeedBasedOnLocationUpdates = nil
            avgWindowSpeedBasedOnSpeedProperties = nil
            currentSpeedBasedOnLocationUpdates = nil
            currentSpeedBasedOnSpeedProperties = nil
            return
        }
        
        // Calculate the rest from the speed properties
        let validSpeedProperties = locations.filter({ $0.speed >= 0.0 }).map({ $0.speed })
        if !validSpeedProperties.isEmpty {
            avgSpeedBasedOnSpeedProperties = validSpeedProperties.reduce(0.0, +) / Double(validSpeedProperties.count)
        }
        
        if let timeWindow = timeWindow {
            let now = Date()
            let windowLocations = locations.filter({ now.timeIntervalSince($0.timestamp) < timeWindow}).sorted(by: { $0.timestamp > $1.timestamp })
            let windowValidSpeedProperties = windowLocations.filter({ $0.speed >= 0.0 }).map({ $0.speed })
            if !windowValidSpeedProperties.isEmpty {
                avgWindowSpeedBasedOnSpeedProperties = windowValidSpeedProperties.reduce(0.0, +) / Double(windowValidSpeedProperties.count)
            }
        }
        
        if locations.last?.speed ?? -1.0 >= 0.0 {
            currentSpeedBasedOnSpeedProperties = locations.last?.speed
        }
        
        if locations.count < 2 {
            // If only one location is provided then we cannot calculate distance/time diff, therefore we cannot
            // calculate any of the speed properties based on the location updates.
            distanceCovered = nil
            totalDuration = nil
            avgSpeedBasedOnLocationUpdates = nil
            avgWindowSpeedBasedOnLocationUpdates = nil
            currentSpeedBasedOnLocationUpdates = nil
            return
        }
        
        var distanceCoveredSoFar: CLLocationDistance = 0.0
        for (index, location) in locations.enumerated() where index > 0 {
            guard let previousLocation = locations.item(before: location) else { continue }
            let diff = location.distance(from: previousLocation)
            distanceCoveredSoFar += diff
        }
        
        if distanceCoveredSoFar == Double.infinity {
            distanceCovered = nil
        } else {
            distanceCovered = CLLocationDistance(distanceCoveredSoFar)
        }
        
        let duration = locations.first!.timestamp.timeIntervalSince(locations.last!.timestamp)
        if duration == Double.infinity || duration == 0.0 {
            totalDuration = nil
        } else {
            totalDuration = duration
        }
        
        if let distance = distanceCovered, let duration = totalDuration {
            avgSpeedBasedOnLocationUpdates = CLLocationSpeed(distance / duration)
        }
        
        if let timeWindow = timeWindow {
            let now = Date()
            let windowLocations = locations.filter({ now.timeIntervalSince($0.timestamp) < timeWindow}).sorted(by: { $0.timestamp > $1.timestamp })
            
            if windowLocations.count > 1 {
                var windowDistanceCoveredSoFar: CLLocationDistance = 0.0
                for (index, location) in locations.enumerated() where index > 0 {
                    guard let previousLocation = locations.item(before: location) else { continue }
                    let diff = location.distance(from: previousLocation)
                    
                    // Apply the distance window.
                    if let distanceWindow = distanceWindow {
                        if distanceCoveredSoFar + diff >= distanceWindow {
                            break
                        }
                    }
                    windowDistanceCoveredSoFar += diff
                }
            
                let windowDuration = windowLocations.first!.timestamp.timeIntervalSince(windowLocations.last!.timestamp)
                
                if windowDistanceCoveredSoFar != Double.infinity && windowDuration != 0.0 && windowDuration != Double.infinity {
                    avgWindowSpeedBasedOnLocationUpdates = CLLocationSpeed(windowDistanceCoveredSoFar / windowDuration)
                }
            }
        }
        
        let lastTwoLocations = locations.suffix(2)
        let currentDistance = lastTwoLocations.first!.distance(from: lastTwoLocations.last!)
        let currentDuration = lastTwoLocations.first!.timestamp.timeIntervalSince(lastTwoLocations.last!.timestamp)
        
        if currentDistance != Double.infinity && currentDuration != 0.0 && currentDuration != Double.infinity {
            currentSpeedBasedOnLocationUpdates = CLLocationSpeed(currentDistance / currentDuration)
        }
    }
}

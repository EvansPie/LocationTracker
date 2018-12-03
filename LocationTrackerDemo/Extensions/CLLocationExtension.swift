//
//  CLLocationExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 10/29/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

public typealias CLLocationPace = Double

extension CLLocation {
    
    func isBetter(than oldLocation: CLLocation?) -> Bool {
        // If there isn't an *oldLocation* (i.e. this is the first location that we're comparing) then return true.
        guard let oldLocation = oldLocation else { return false }
        
        // If this is the same object as the *oldLocation* return false.
        if self == oldLocation { return false }
        
        // Check if horizontal accuracy is negative, which means an invalid location.
        if horizontalAccuracy < 0 { return false }
        
        // Check against location's age.
        let now = Date()
        if now.timeIntervalSince(timestamp) > LocationTracker.shared.resolution.invalidTimestampAge { return false }
        
        // Check acceleration
        // ...
        
        
        // Time interval between the two locations we're comparing
        let timeDelta: TimeInterval = timestamp.timeIntervalSince(oldLocation.timestamp)
        
        // Distance interval between the two locations we're comparing
        let distanceDelta: CLLocationDistance = distance(from: oldLocation)
        
        // Horizontal accuracy difference between the two locations we're comparing.
        // A negative value indicates that the new location is more accurate.
        let horizontalAccuracyDelta: CLLocationAccuracy = horizontalAccuracy - oldLocation.horizontalAccuracy
        
        let isSignificantlyNewer: Bool = timeDelta > LocationTracker.shared.resolution.significantlyNewerTimeInterval
        let isNewer: Bool = timeDelta >= 0
//        let isOlder: Bool = timeDelta < 0
        let isSignificantlyOlder: Bool = timeDelta < LocationTracker.shared.resolution.significantlyNewerTimeInterval
        
        let isHorizontallySignificantlyLessAccurate: Bool = horizontalAccuracyDelta > LocationTracker.shared.resolution.significantAccuracyChange
//        let isHorizontallyLessAccurate: Bool = horizontalAccuracyDelta > 0
        let isHorizontallyMoreAccurate: Bool = horizontalAccuracyDelta < 0
        let isHorizontallySignificantlyMoreAccurate: Bool = horizontalAccuracyDelta < -LocationTracker.shared.resolution.significantAccuracyChange
        
        // If it's significantly older or significantly less accurate than the previous location, discard it immediately.
        if isSignificantlyOlder || isHorizontallySignificantlyLessAccurate {
            return false
        }
        
        // If it's significantly more accurate and not older then keep it.
        if isHorizontallySignificantlyMoreAccurate && isNewer {
            return true
        }
        
        // If it's significantly newer and more accurate keep it.
        if isSignificantlyNewer && isHorizontallyMoreAccurate {
            return true
        }
        
        // If it's (a bit) newer & (a bit) more accurate then keep it.
        if isNewer && isHorizontallyMoreAccurate {
            return true
        }
        
        // If we're here then the location update is (a bit) newer and less accurate or (a bit) more accurate and older.
        // If a location update is not needed at the moment, discard it.
        
        let needsDistanceUpdate: Bool = distanceDelta > LocationTracker.shared.resolution.significantDistanceChange
        if !needsDistanceUpdate {
            return false
        }
        
        if needsDistanceUpdate && (isNewer || isHorizontallyMoreAccurate) && (!isSignificantlyOlder || !isHorizontallySignificantlyLessAccurate) {
            return true
        }
        
        return false
    }
    
    var JSONRepresentation: [String: Any] {
        return [
            "coordinate": ["latitude": coordinate.latitude, "longitude": coordinate.longitude],
            "horizontalAccuracy": horizontalAccuracy,
            "verticalAccuracy": verticalAccuracy,
            "speed": speed,
            "course": course,
            "timestamp": timestamp.toString(),
            "altitude": altitude
        ]
    }
    
    var pace: CLLocationPace {
        return speed.toPace()
    }
}

extension CLLocationDistance {
    
    enum DistanceUnit: Double {
        case mm   = 0.001
        case cm   = 0.01
        case m    = 1
        case km   = 1000
        case inch = 0.0254
        case ft   = 0.3048
        case mi   = 1609.344
        case lea  = 4828.032
        case nmi  = 1852
        
        var description: String {
            switch self {
            case .mm:
                return "milimeter"
            case .cm:
                return "centimeter"
            case .m:
                return "meter"
            case .km:
                return "kilometer"
            case .inch:
                return "inch"
            case .ft:
                return "feet"
            case .mi:
                return "mile"
            case .lea:
                return "league"
            case .nmi:
                return "nautical mile"
            }
        }
        
        var shortHand: String {
            switch self {
            case .mm:
                return "mm"
            case .cm:
                return "cm"
            case .m:
                return "m"
            case .km:
                return "km"
            case .inch:
                return "in"
            case .ft:
                return "ft"
            case .mi:
                return "mi"
            case .lea:
                return "lea"
            case .nmi:
                return "n-mi"
            }
        }
    }
    
    /**
     Converts a distance to another **unit**. **initialUnit** has default value *meters*.
     
     **IMPORTANT**
     
     Remember to always provide a correct **initialUnit** or leave it empty in case the initial unit is *meters*.
     */
    func to(_ unit: DistanceUnit, from initialUnit: DistanceUnit = .m) -> CLLocationDistance {
        return (self * unit.rawValue) / initialUnit.rawValue
    }
    
    /**
     Helper function that provides a human readable distance.
     
     **IMPORTANT**
     
     Remember to always provide a correct **initialUnit** or leave it empty in case the initial unit is *meters*.
     */
    func toString(unit: DistanceUnit = .m, from initialUnit: DistanceUnit = .m, decimalPlaces: Int = 2, includeUnit: Bool = false) -> String {
        let value = to(unit, from: initialUnit)
        return String(format: "%.\(decimalPlaces)f", value) + (includeUnit ? " \(unit.shortHand)" : "")
    }
    
}

extension TimeInterval {
    
    enum TimeUnit: Double {
        case sec   = 1
        case min   = 60
        case h     = 3600
        
        var description: String {
            switch self {
            case .sec:
                return "seconds"
            case .min:
                return "minutes"
            case .h:
                return "hours"
            }
        }
        
        var shortHand: String {
            switch self {
            case .sec:
                return "sec"
            case .min:
                return "min"
            case .h:
                return "h"
            }
        }
    }
    
    func to(_ unit: TimeUnit, from initialUnit: TimeUnit = .sec) -> Double {
        return (self * unit.rawValue) / initialUnit.rawValue
    }
    
    func toString(unit: TimeUnit = .sec, from initialUnit: TimeUnit = .sec, decimalPlaces: Int = 2, includeUnit: Bool = false) -> String {
        let value = to(unit, from: initialUnit)
        return String(format: "%.\(decimalPlaces)f", value) + (includeUnit ? " \(unit.shortHand)" : "")
    }
    
}

extension CLLocationSpeed {
    
    func to(_ distanceUnit: DistanceUnit, per timeUnit: TimeUnit) -> CLLocationSpeed {
        return (self * timeUnit.rawValue) / (distanceUnit.rawValue)
    }
    
    func toString(distanceUnit: DistanceUnit = .m, timeUnit: TimeUnit = .sec, decimalPlaces: Int = 2, includeUnit: Bool = false) -> String {
        let value = to(distanceUnit, per: timeUnit)
        return String(format: "%.\(decimalPlaces)f", value) + (includeUnit ? " \(distanceUnit.shortHand)/\(timeUnit.shortHand)" : "")
    }
    
    func toPace() -> CLLocationPace {
        return 1 / self
    }
    
    func toPaceString(timeUnit: TimeUnit = .sec, distanceUnit: DistanceUnit = .m, decimalPlaces: Int = 2, includeUnit: Bool = false) -> String {
        if timeUnit == .min && distanceUnit == .km {
            return to(.km, per: .sec).toRunningPaceStr()
        }
        
        let value = to(distanceUnit, per: timeUnit).toPace()
        return String(format: "%.\(decimalPlaces)f", value) + (includeUnit ? " \(timeUnit.shortHand)/\(distanceUnit.shortHand)" : "")
    }
    
}

extension CLLocationPace {
    
    func toRunningPaceStr() -> String {
        // Input must be pace normalized (i.e. sec/m)
        let nv = self * 1000
        if nv <= 0.0 || nv == Double.infinity { return "0'00\""}
        let mins = Int(floor(nv/60.0))
        let sec = Int(nv.truncatingRemainder(dividingBy: 60.0))
        return "\(mins)'\(String(format: "%02d", sec))\""
    }
    
}

//
//  LocationTrackerResolution.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/2/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

extension LocationTracker {
    
    enum Resolution {
        case idle(isBatterySavingEnabled: Bool), walk(isBatterySavingEnabled: Bool), jog(isBatterySavingEnabled: Bool), run(isBatterySavingEnabled: Bool), cycle(isBatterySavingEnabled: Bool), drive(isBatterySavingEnabled: Bool), speeding(isBatterySavingEnabled: Bool)
        case custom(
            name: String,
            activityType: CLActivityType,
            allowsBackgroundLocationUpdates: Bool,
            desiredAccuracy: CLLocationAccuracy,
            distanceFilter: CLLocationDistance,
            invalidTimestampAge: TimeInterval,
            significantlyNewerTimeInterval: TimeInterval,
            significantDistanceChange: CLLocationDistance,
            significantAccuracyChange: CLLocationAccuracy
        )
        
        var name: String {
            switch self {
            case .idle:
                return "idle"
            case .walk:
                return "walk"
            case .jog:
                return "jog"
            case .run:
                return "run"
            case .cycle:
                return "cycle"
            case .drive:
                return "drive"
            case .speeding:
                return "speedding"
            case .custom(let name, _, _, _, _, _, _, _, _):
                return name
            }
        }
        
        var activityType: CLActivityType {
            switch self {
            case .idle:
                return CLActivityType.fitness
            case .walk:
                return CLActivityType.fitness
            case .jog:
                return CLActivityType.fitness
            case .run:
                return CLActivityType.fitness
            case .cycle:
                return CLActivityType.fitness
            case .drive:
                return CLActivityType.automotiveNavigation
            case .speeding:
                return CLActivityType.automotiveNavigation
            case .custom(_, let activityType, _, _, _, _, _, _, _):
                return activityType
            }
        }
        
        var allowsBackgroundLocationUpdates: Bool {
            switch self {
            case .idle(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .walk(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .jog(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .run(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .cycle(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .drive(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .speeding(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? false : true
            case .custom(_, _, let allowsBackgroundLocationUpdates, _, _, _, _, _, _):
                return allowsBackgroundLocationUpdates
            }
        }
        
        /** The desired accureacy of the location data. There's no guarantee that it will be achieved.
         */
        var desiredAccuracy: CLLocationAccuracy {
            switch self {
            case .idle(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? kCLLocationAccuracyNearestTenMeters : kCLLocationAccuracyBest
            case .walk(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? kCLLocationAccuracyNearestTenMeters : kCLLocationAccuracyBest
            case .jog(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? kCLLocationAccuracyNearestTenMeters : kCLLocationAccuracyBest
            case .run(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? kCLLocationAccuracyNearestTenMeters : kCLLocationAccuracyBest
            case .cycle(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? kCLLocationAccuracyHundredMeters : kCLLocationAccuracyNearestTenMeters
            case .drive(let isBatterySavingEnabled):
                return kCLLocationAccuracyBestForNavigation
            case .speeding(let isBatterySavingEnabled):
                return kCLLocationAccuracyBestForNavigation
            case .custom(_, _, _, let desiredAccuracy, _, _, _, _, _):
                return desiredAccuracy
            }
        }
        
        /** The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
         */
        var distanceFilter: CLLocationDistance {
            switch self {
            case .idle(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 1.5 : kCLDistanceFilterNone
            case .walk(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 3.0 : kCLDistanceFilterNone
            case .jog(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 4.0 : 2.0
            case .run(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 5.0 : 3.0
            case .cycle(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 20.0 : 10.0
            case .drive(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 50.0 : 30.0
            case .speeding(let isBatterySavingEnabled):
                return isBatterySavingEnabled ? 100.0 : 50.0
            case .custom(_, _, _, _, let distanceFilter, _, _, _, _):
                return distanceFilter
            }
        }
        
        /** A constant indicating that if a location's timestamp is older than that, it shouldn't be taken into account.
         */
        var invalidTimestampAge: TimeInterval {
            switch self {
            case .idle:
                return 300.0
            case .walk:
                return 150.0
            case .jog:
                return 100.0
            case .run:
                return 60.0
            case .cycle:
                return 50.0
            case .drive:
                return 20.0
            case .speeding:
                return 10.0
            case .custom(_, _, _, _, _, let invalidTimestampAge, _, _, _):
                return invalidTimestampAge
            }
        }
        
        /** A constant indicating that if a location's timestamp is newer than that, it should be considered significantly newer than the older one, thus we should take it into account
         */
        var significantlyNewerTimeInterval: TimeInterval {
            switch self {
            case .idle:
                return 30.0
            case .walk:
                return 15.0
            case .jog:
                return 10.0
            case .run:
                return 6.0
            case .cycle:
                return 5.0
            case .drive:
                return 2.0
            case .speeding:
                return 1.0
            case .custom(_, _, _, _, _, _, let significantlyNewerTimeInterval, _, _):
                return significantlyNewerTimeInterval
            }
        }
        
        /** A constant indicating that if the new location distance has a significant distance change from the old one, it should be  taken it into account.
         */
        var significantDistanceChange: CLLocationDistance {
            switch self {
            case .idle:
                return 0.5
            case .walk:
                return 1.0
            case .jog:
                return 2.0
            case .run:
                return 3.0
            case .cycle:
                return 10.0
            case .drive:
                return 50.0
            case .speeding:
                return 100.0
            case .custom(_, _, _, _, _, _, _, let significantDistanceChange, _):
                return significantDistanceChange
            }
        }
        
        /** A constant indicating that if the new location is more accurate by this constant, it should be  taken it into account.
         */
        var significantAccuracyChange: CLLocationAccuracy {
            switch self {
            case .idle:
                return 10.0
            case .walk:
                return 10.0
            case .jog:
                return 10.0
            case .run:
                return 10.0
            case .cycle:
                return 10.0
            case .drive:
                return 10.0
            case .speeding:
                return 10.0
            case .custom(_, _, _, _, _, _, _, _, let significantAccuracyChange):
                return significantAccuracyChange
            }
        }
        
        var recognitionInterval: TimeInterval {
            return 10.0
        }
    }
    
}

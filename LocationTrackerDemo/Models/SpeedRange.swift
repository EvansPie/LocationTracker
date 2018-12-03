//
//  SpeedRange.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/2/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

struct SpeedRange {
    let minSpeed: CLLocationSpeed
    let maxSpeed: CLLocationSpeed
    var avgSpeed: CLLocationSpeed { return (minSpeed + maxSpeed)/2 }
}

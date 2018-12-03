//
//  LocationTrackerConstants.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/2/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import Foundation

extension LocationTracker {
    
    static var walkingSpeedRange:  SpeedRange = SpeedRange(minSpeed:  0.33, maxSpeed:  1.58)
    static var jogginggSpeedRange: SpeedRange = SpeedRange(minSpeed:  1.58, maxSpeed:  3.02)    // 10'00" - 6'00" per km
    static var runningSpeedRange:  SpeedRange = SpeedRange(minSpeed:  3.02, maxSpeed:  4.76)    //  6'00" - 3'30" per km
    static var cyclingSpeedRange:  SpeedRange = SpeedRange(minSpeed:  2.77, maxSpeed:  8.33)    //  10 -  30 kmph
    static var drivingSpeedRange:  SpeedRange = SpeedRange(minSpeed:  8.33, maxSpeed: 27.78)    //  30 - 100 kmph
    static var speedingSpeedRange: SpeedRange = SpeedRange(minSpeed: 27.78, maxSpeed: 83.34)    // 100 - 300 kmph

    func mostProbableResolution() {
        
    }
}

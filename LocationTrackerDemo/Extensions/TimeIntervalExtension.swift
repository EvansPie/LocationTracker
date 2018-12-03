//
//  TimeIntervalExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    func toMinutes() -> TimeInterval {
        return self / 60.0
    }
    
    func toHours() -> TimeInterval {
        return self / 3600.0
    }
    
    func toSecStr() -> String {
        return String(format: "%.0f", self) + " sec"
    }
    
    func toMinsStr() -> String {
        return String(format: "%.0f", toMinutes()) + " min(s)"
    }
    
    func toHoursStr() -> String {
        return String(format: "%.0f", toHours()) + " hour(s)"
    }
    
    func normalizedDurationStr() -> String {
        let hours = Int(floor(self / 3600))
        let mins = Int(floor((self - Double(hours)*3600) / 60))
        let sec = Int(floor(self - Double(mins)*60.0 - Double(hours*3600)))
        
        if hours > 0 {
            return "\(String(format: "%02d", hours)):\(String(format: "%02d", mins)):\(String(format: "%02d", sec))"
        } else if mins > 0 {
            return "\(String(format: "%02d", mins)):\(String(format: "%02d", sec))"
        } else {
            return "\(String(format: "%02d", sec))"
        }
    }
    
}

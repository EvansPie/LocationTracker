//
//  LocationTrackerPowerSaveOption.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/2/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import Foundation

extension LocationTracker {
    enum PowerSaveOption: Int {
        case auto, on, off
        
        var isBatterySavingEnabled: Bool {
            return true
        }
        
        var description: String {
            switch self {
            case .auto:
                return "auto"
            case .on:
                return "on"
            case .off:
                return "off"
            }
        }
    }
}

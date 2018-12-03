//
//  DateExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import Foundation

extension Date {
    
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ") -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: self)
    }
    
}


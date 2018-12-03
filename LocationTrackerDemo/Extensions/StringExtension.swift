//
//  StringExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import Foundation

extension String {
    
    func toDate() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.date(from: self)
    }
    
}

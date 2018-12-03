//
//  CollectionExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import Foundation

extension Collection where Iterator.Element == CLLocation {
    
    func getMetadata(forlastTimeInterval timeWindow: TimeInterval? = nil, forDistanceLimit distanceLimit: CLLocationDistance? = nil) -> LocationCollectionMetadata? {
        let tmpLocations: [CLLocation] = self.map({ $0 })
        return LocationCollectionMetadata(locations: tmpLocations, timeWindow: timeWindow)
    }
    
}

extension Collection where Element: BinaryInteger {
    var sum: Element { return reduce(0, +) }
    var average: Double {
        return isEmpty ? 0 : Double(sum) / Double(count)
    }
}

extension Collection where Element: BinaryFloatingPoint {
    var sum: Element { return reduce(0, +) }
    var average: Element {
        return isEmpty ? 0 : sum / Element(count)
    }
}

extension BidirectionalCollection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element
    
    func safeIndex(before index: Index) -> Index? {
        let previousIndex = self.index(before: index)
        return (self.startIndex <= previousIndex) ? previousIndex : nil
    }
    
    func item(before item: Element) -> Element? {
        return self.index(of: item).flatMap(self.safeIndex(before:)).map{ self[$0] }
    }
}

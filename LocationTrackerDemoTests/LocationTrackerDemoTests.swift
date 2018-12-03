//
//  LocationTrackerDemoTests.swift
//  LocationTrackerDemoTests
//
//  Created by Vangelis Pittas on 10/29/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import XCTest
@testable import LocationTrackerDemo

class LocationTrackerDemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let filePathStr = Bundle.main.path(forResource: "walking-on-terrace", ofType: "json"), let filePath = URL(string: "file://\(filePathStr)") else { return }
        let jsonData = try! Data(contentsOf: filePath)
        guard let locationsJSONArray = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [[[String: Any]]] else { return }
        let locations = locationsJSONArray.compactMap({ $0.compactMap({ $0.location}) })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

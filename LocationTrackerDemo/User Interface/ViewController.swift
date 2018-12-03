//
//  ViewController.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 10/29/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import MessageUI
import UIKit

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var authStatusLabel: UILabel!
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var enabledLabel: UILabel!
    @IBOutlet weak var resolutionLabel: UILabel!
    @IBOutlet weak var batterySaveOptionLabel: UILabel!
    @IBOutlet weak var batterySavingLabel: UILabel!
    
    @IBOutlet weak var debugRecordingLabel: UILabel!
    @IBOutlet weak var recordedDebugLocationsLabel: UILabel!
    @IBOutlet weak var gpxRecordingLabel: UILabel!
    @IBOutlet weak var recordedGPXLocationsLabel: UILabel!
    
    @IBOutlet weak var sessionLocationsLabel: UILabel!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var locationBasedTotalAvgMetersPerSecLabel: UILabel!
    @IBOutlet weak var locationBasedTotalAvgKmPerHourLabel: UILabel!
    @IBOutlet weak var locationBasedWindowAvgMetersPerSecLabel: UILabel!
    @IBOutlet weak var locationBasedWindowAvgKmPerHourLabel: UILabel!
    @IBOutlet weak var locationBasedCurrentAvgMetersPerSecLabel: UILabel!
    @IBOutlet weak var locationBasedCurrentAvgKmPerHourLabel: UILabel!
    @IBOutlet weak var speedPropsBasedTotalAvgMetersPerSecLabel: UILabel!
    @IBOutlet weak var speedPropsBasedTotalAvgKmPerHourLabel: UILabel!
    @IBOutlet weak var speedPropsBasedWindowAvgMetersPerSecLabel: UILabel!
    @IBOutlet weak var speedPropsBasedWindowAvgKmPerHourLabel: UILabel!
    @IBOutlet weak var speedPropsBasedCurrentAvgMetersPerSecLabel: UILabel!
    @IBOutlet weak var speedPropsBasedCurrentAvgKmPerHourLabel: UILabel!
    @IBOutlet weak var locationBasedTotalAvgPaceLabel: UILabel!
    @IBOutlet weak var locationBasedWindowAvgPaceLabel: UILabel!
    @IBOutlet weak var locationBasedCurrentAvgPaceLabel: UILabel!
    @IBOutlet weak var speedPropsBasedTotalAvgPaceLabel: UILabel!
    @IBOutlet weak var speedPropsBasedWindowAvgPaceLabel: UILabel!
    @IBOutlet weak var speedPropsBasedCurrentAvgPaceLabel: UILabel!

    private var dummyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        render()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            self.render()
        }
    }

    func render() {
        authStatusLabel.text = LocationTracker.shared.authStatusDescription
        permissionLabel.text = LocationTracker.shared.permissionDescription
        enabledLabel.text = LocationTracker.shared.isEnabled ? "Yes" : "No"
        resolutionLabel.text = LocationTracker.shared.resolution.name
        batterySaveOptionLabel.text = " | Power save: \(LocationTracker.shared.powerSaveOption.description)"
        batterySavingLabel.text = LocationTracker.shared.isBatterySavingEnabled ? "Yes" : "No"
        
        debugRecordingLabel.text = LocationTracker.shared.isDebugRecording ? "Yes" : "No"
        recordedDebugLocationsLabel.text = String(LocationTracker.shared.recordedDebugLocations.flatMap({ $0 }).count)
        gpxRecordingLabel.text = LocationTracker.shared.isGPXRecording ? "Yes" : "No"
        recordedGPXLocationsLabel.text = String(LocationTracker.shared.recordedGPXLocations.count)

        let locationTrackerMetadata = LocationTracker.shared.sessionLocations.getMetadata(forlastTimeInterval: 10.0, forDistanceLimit: nil)
        sessionLocationsLabel.text = String(locationTrackerMetadata?.locations.count ?? 0)
        distanceCoveredLabel.text = locationTrackerMetadata?.distanceCovered?.toString(unit: .m, includeUnit: true)
        totalDurationLabel.text = locationTrackerMetadata?.totalDuration?.toSecStr()
        
        // FIRST COLUMN (SPEED BASED ON LOCATION UPDATES)
        locationBasedTotalAvgMetersPerSecLabel.text = locationTrackerMetadata?.avgSpeedBasedOnLocationUpdates?.toString(distanceUnit: .m, timeUnit: .sec)
        locationBasedTotalAvgKmPerHourLabel.text = locationTrackerMetadata?.avgSpeedBasedOnLocationUpdates?.toString(distanceUnit: .km, timeUnit: .h)
        locationBasedWindowAvgMetersPerSecLabel.text = locationTrackerMetadata?.avgWindowSpeedBasedOnLocationUpdates?.toString(distanceUnit: .m, timeUnit: .sec)
        locationBasedWindowAvgKmPerHourLabel.text = locationTrackerMetadata?.avgWindowSpeedBasedOnLocationUpdates?.toString(distanceUnit: .km, timeUnit: .h)
        locationBasedCurrentAvgMetersPerSecLabel.text = locationTrackerMetadata?.currentSpeedBasedOnLocationUpdates?.toString(distanceUnit: .m, timeUnit: .sec)
        locationBasedCurrentAvgKmPerHourLabel.text = locationTrackerMetadata?.currentSpeedBasedOnLocationUpdates?.toString(distanceUnit: .km, timeUnit: .h)
        
        // SECOND COLUMN (SPEED BASED ON SPEED PROPERTIES)
        speedPropsBasedTotalAvgMetersPerSecLabel.text = locationTrackerMetadata?.avgSpeedBasedOnSpeedProperties?.toString(distanceUnit: .m, timeUnit: .sec)
        speedPropsBasedTotalAvgKmPerHourLabel.text = locationTrackerMetadata?.avgSpeedBasedOnSpeedProperties?.toString(distanceUnit: .km, timeUnit: .h)
        speedPropsBasedWindowAvgMetersPerSecLabel.text = locationTrackerMetadata?.avgWindowSpeedBasedOnSpeedProperties?.toString(distanceUnit: .m, timeUnit: .sec)
        speedPropsBasedWindowAvgKmPerHourLabel.text = locationTrackerMetadata?.avgWindowSpeedBasedOnSpeedProperties?.toString(distanceUnit: .km, timeUnit: .h)
        speedPropsBasedCurrentAvgMetersPerSecLabel.text = locationTrackerMetadata?.currentSpeedBasedOnSpeedProperties?.toString(distanceUnit: .m, timeUnit: .sec)
        speedPropsBasedCurrentAvgKmPerHourLabel.text = locationTrackerMetadata?.currentSpeedBasedOnSpeedProperties?.toString(distanceUnit: .km, timeUnit: .h)

        // PACEC INFO
        locationBasedTotalAvgPaceLabel.text = locationTrackerMetadata?.avgPaceBasedOnLocationUpdates?.toRunningPaceStr()
        locationBasedWindowAvgPaceLabel.text = locationTrackerMetadata?.avgWindowPaceBasedOnLocationUpdates?.toRunningPaceStr()
        locationBasedCurrentAvgPaceLabel.text = locationTrackerMetadata?.currentPaceBasedOnLocationUpdates?.toRunningPaceStr()
        speedPropsBasedTotalAvgPaceLabel.text = locationTrackerMetadata?.avgPaceBasedOnSpeedProperties?.toRunningPaceStr()
        speedPropsBasedWindowAvgPaceLabel.text = locationTrackerMetadata?.avgWindowPaceBasedOnSpeedProperties?.toRunningPaceStr()
        speedPropsBasedCurrentAvgPaceLabel.text = locationTrackerMetadata?.currentPaceBasedOnSpeedProperties?.toRunningPaceStr()

    }
    
    @IBAction func locationTrackerResolutionButtonTapped(_ sender: UIButton) {
        dummyTextField.becomeFirstResponder()
    }

}































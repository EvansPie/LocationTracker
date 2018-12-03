//
//  LocationTracker.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 10/29/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import CoreMotion
import Foundation
import UIKit

private let _LocationTracker = LocationTracker()

typealias EnforceLocationUpdateCompletionHandler = ((CLLocation?, Error?) -> Void)

class LocationTracker: NSObject {
    
    // MARK: - PROPERTIES
    
    private var _resolution: LocationTracker.Resolution = .idle(isBatterySavingEnabled: false)
    var resolution: LocationTracker.Resolution {
        get {
            return _resolution
        }
        set {
//            if newValue == _resolution { return }
            // If the resolution gets set manually, disable automatic resolution change
//            allowAutomaticResolutionChange = false
            
            switch newValue {
            case .idle:
                _resolution = .idle(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .walk:
                _resolution = .walk(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .jog:
                _resolution = .jog(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .run:
                _resolution = .run(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .cycle:
                _resolution = .cycle(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .drive:
                _resolution = .drive(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .speeding:
                _resolution = .speeding(isBatterySavingEnabled: self.isBatterySavingEnabled)
            case .custom:
                _resolution = newValue
            }
            
            self.setup()
        }
    }
    var isEnabled: Bool = false
    var allowAutomaticResolutionChange: Bool = true
    var powerSaveOption: PowerSaveOption = .auto {
        didSet {
            if powerSaveOption == .on {
                isBatterySavingEnabled = true
            } else if powerSaveOption == .off {
                isBatterySavingEnabled = false
            } else {
                isBatterySavingEnabled = 0.0...0.3 ~= batteryLevel
            }
        }
    }
    /**
     **isBatterySavingEnabled** defines whether battery saving is enabled.
     - *true* if **powerSaveOption** is *on* or if **powerSaveOption** is *auto* and **batteryLevel** is above 30%
     - *false* if **powerSaveOption** is *off* or if **powerSaveOption** is *auto* and **batteryLevel** is below 30%
     */
    private(set) var isBatterySavingEnabled: Bool = false
    
    /**  If *allowBackgroundLocationUpdates* is set to false, then the LocationTracker will stop the location updates when it gets into the background, and restart them when it gets into the foreground.
     */
    var allowBackgroundLocationUpdates: Bool {
        get {
            return locationManager.allowsBackgroundLocationUpdates
        }
        set {
            locationManager.allowsBackgroundLocationUpdates = newValue
        }
    }
    
    var locationManager: CLLocationManager = CLLocationManager()
    private var enforceLocationUpdateCompletion: EnforceLocationUpdateCompletionHandler?

    /**
     **location** stores the last best *CLLocation* object returned in the **[CLLocation]** array on **locationManager(_:didUpdateLocations:)**. Filtering is performed by the **isBetter(than:_)** extension.
     */
    fileprivate(set) var location: CLLocation?
    /**
     **bestLocation** stores the last best *CLLocation* object compared with the previous **location** object.
     */
    fileprivate(set) var bestLocation: CLLocation?
    
    /**
     **sessionLocations** stores the best *CLLocation* object returned in the **[CLLocation]** array on **locationManager(_:didUpdateLocations:)**. Filtering is performed by the **isBetter(than:_)** extension.
     */
    fileprivate(set) var sessionLocations = [CLLocation]()
    
    /**
     **recordedDebugLocations** stores all *CLLocation* objects returned in **locationManager(_:didUpdateLocations:)** if **isDebugRecording** is set to *true*. They can be used to create files for unit testing.
     */
    var recordedDebugLocations: [[CLLocation]] = []
    /**
     **isDebugRecording** starts/stops *CLLocation* objects from being stored in **recordedDebugLocations**. When it is set to *true*, it resets all previously stored location objects. Default value is *false*
     */
    var isDebugRecording: Bool = false// { didSet {  if isDebugRecording == true { recordedDebugLocations = [] } } }
    
    /**
     **recordedGPXLocations** stores the best *CLLocation* object returned in the **[CLLocation]** array on **locationManager(_:didUpdateLocations:)** if **isGPXRecording** is set to *true*. Filtering is performed by the **isBetter(than:_)** extension. They can be used to create GPX files for debugging.
     */
    var recordedGPXLocations: [CLLocation] = []
    /**
     **isGPXRecording** starts/stops *CLLocation* objects from being stored in **recordedGPXLocations**. When it is set to *true*, it resets all previously stored location objects. Default value is *false*
     */
    var isGPXRecording: Bool = false// { didSet {  if isGPXRecording == true { recordedGPXLocations = [] } } }
    
    private var locationUpdateFailsafeTimer: Timer?
    
    
    private var batteryLevel: Float { return UIDevice.current.batteryLevel }
    private var batteryState: UIDevice.BatteryState { return UIDevice.current.batteryState }
    
    
    // MARK: - SINGLETON INITIALIZATION
    
    class var shared: LocationTracker { return _LocationTracker }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate override init() {
        super.init()
        addNotificationObservers()
        setup()
    }
    
    
    // MARK: - NOTIFICATION CENTER
    
    private func addNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTracker.received(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTracker.received(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTracker.received(notification:)), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTracker.received(notification:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    
    @objc private func received(notification: Notification) {
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            if !allowBackgroundLocationUpdates { try? enable(false) }
            
        case UIApplication.didBecomeActiveNotification:
            try? enable(true)
            
        case UIDevice.batteryStateDidChangeNotification, UIDevice.batteryLevelDidChangeNotification:
            if powerSaveOption != .auto { return }
            switch batteryState {
            case .unplugged, .unknown, .charging:
                isBatterySavingEnabled = batteryLevel <= 0.3
            case .full:
                isBatterySavingEnabled = false
            }
            setup()
            
        default:
            break
        }
    }
    
    
    // MARK: - SETUP
    
    private func setup() {
        locationManager.delegate = self
        locationManager.activityType = _resolution.activityType
        locationManager.allowsBackgroundLocationUpdates = _resolution.allowsBackgroundLocationUpdates
        locationManager.desiredAccuracy = _resolution.desiredAccuracy
        locationManager.distanceFilter = _resolution.distanceFilter
    }
    
    func enable(_ enable: Bool) throws {
        if enable && !isEnabled {
            if !CLLocationManager.locationServicesEnabled() {
                let error = NSError(domain: "LocationTracker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled for all apps."])
                isEnabled = false
                throw error
            } else {
                switch hasPermission {
                case true?:
                    locationManager.startUpdatingLocation()
                    isEnabled = true
                    
                case false?:
                    let error = NSError(domain: "LocationTracker", code: 2, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled for \(Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)."])
                    print(error)
                    throw error
                    
                default:
                    let error = NSError(domain: "LocationTracker", code: 0, userInfo: [NSLocalizedDescriptionKey: "User hasn't been prompted to grant permission for Location services access."])
                    print(error)
                    throw error
                }
            }
        } else if !enable && isEnabled {
            locationManager.stopUpdatingLocation()
            isEnabled = false
        }
    }
    
    
    // MARK: - HELPERS
    
    func enforceLocationUpdate(completion: EnforceLocationUpdateCompletionHandler?) {
        enforceLocationUpdateCompletion = completion
        if !CLLocationManager.locationServicesEnabled() {
            let error = NSError(domain: "LocationTracker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled for all apps."])
            enforceLocationUpdateCompletion?(nil, error)
        } else {
            switch hasPermission {
            case true?:
                locationManager.requestLocation()
                
            case false?:
                let error = NSError(domain: "LocationTracker", code: 2, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled for \(Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)."])
                enforceLocationUpdateCompletion?(nil, error)
                
            default:
                let error = NSError(domain: "LocationTracker", code: 0, userInfo: [NSLocalizedDescriptionKey: "User hasn't been prompted to grant permission for Location services access."])
                enforceLocationUpdateCompletion?(nil, error)
            }
        }
    }
    
    
    // MARK: - AUTHORIZATION
    
    var authStatusDescription: String {
        if !CLLocationManager.locationServicesEnabled() {
            return "Location services are disabled for all apps."
        } else {
            switch hasPermission {
            case true?:
                return "Location services are enabled."
                
            case false?:
                return "Location services are disabled for \(Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)."
                
            default:
                return "Not prompted"
            }
        }
    }
    
    var permissionDescription: String {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return "Authorized always"
        case .authorizedWhenInUse:
            return "Authorized when in use"
        case .notDetermined:
            return "Not determined"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        }
    }
    
    var hasPermission: Bool? {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            return nil
        default:
            return false
        }
    }
    
    func requestAuthorization(for authorizationType: CLAuthorizationStatus) {
        switch authorizationType {
        case .authorizedAlways:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
}


// MARK: - DELEGATE

extension LocationTracker: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Invalidate failsafe timer.
        locationUpdateFailsafeTimer?.invalidate()
        locationUpdateFailsafeTimer = nil
        
        if isDebugRecording { recordedDebugLocations.append(locations) }
        
        guard let bestReturnedLocation = locations.sorted(by: { $0.isBetter(than: $1) }).first else { return }
        
        sessionLocations.append(bestReturnedLocation)
        if isGPXRecording { recordedGPXLocations.append(bestReturnedLocation) }
        
        if bestReturnedLocation.isBetter(than: location) { bestLocation = bestReturnedLocation }
        location = bestReturnedLocation
        
        if allowAutomaticResolutionChange, let locationsMetadata = sessionLocations.getMetadata(forlastTimeInterval: 10.0, forDistanceLimit: nil) {
            if locationsMetadata.avgWindowSpeedBasedOnLocationUpdates ?? 0 > LocationTracker.speedingSpeedRange.minSpeed {
                resolution = LocationTracker.Resolution.speeding(isBatterySavingEnabled: isBatterySavingEnabled)
            } else if locationsMetadata.avgWindowSpeedBasedOnLocationUpdates ?? 0 > LocationTracker.drivingSpeedRange.minSpeed {
                resolution = LocationTracker.Resolution.drive(isBatterySavingEnabled: isBatterySavingEnabled)
            } else if locationsMetadata.avgWindowSpeedBasedOnLocationUpdates ?? 0 > LocationTracker.cyclingSpeedRange.minSpeed {
                resolution = LocationTracker.Resolution.cycle(isBatterySavingEnabled: isBatterySavingEnabled)
            } else if locationsMetadata.avgWindowSpeedBasedOnLocationUpdates ?? 0 > LocationTracker.runningSpeedRange.minSpeed {
                resolution = LocationTracker.Resolution.run(isBatterySavingEnabled: isBatterySavingEnabled)
            } else if locationsMetadata.avgWindowSpeedBasedOnLocationUpdates ?? 0 > LocationTracker.jogginggSpeedRange.minSpeed {
                resolution = LocationTracker.Resolution.jog(isBatterySavingEnabled: isBatterySavingEnabled)
            } else if locationsMetadata.avgWindowSpeedBasedOnLocationUpdates ?? 0 > LocationTracker.walkingSpeedRange.minSpeed {
                resolution = LocationTracker.Resolution.walk(isBatterySavingEnabled: isBatterySavingEnabled)
            } else {
                resolution = LocationTracker.Resolution.idle(isBatterySavingEnabled: isBatterySavingEnabled)
            }
        }
        
        if enforceLocationUpdateCompletion != nil {
            enforceLocationUpdateCompletion!(bestReturnedLocation, nil)
            enforceLocationUpdateCompletion = nil
        }
        
        // Add failsafe timer in case the resolution has become really high and then stops suddenly
        locationUpdateFailsafeTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { (_) in
            self.enforceLocationUpdate(completion: nil)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        if enforceLocationUpdateCompletion != nil {
            enforceLocationUpdateCompletion!(nil, error)
            enforceLocationUpdateCompletion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NotificationCenter.default.post(Notification(name: Notification.Name.locationManagerDidChangeAuthStatus))
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
    }
    
}



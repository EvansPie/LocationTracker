//
//  UIApplicationExtension.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/3/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func openSettings(completion: ((_ finished: Bool) -> Void)?) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { (finished) in
            completion?(finished)
        }
    }
    
    func openLocationServicesSettings(completionHandler: ((_ finished: Bool) -> Void)?) {
        UIApplication.shared.open(URL(string: "App-Prefs:root=PRIVACY&path=LOCATION_SERVICES")!, options: [:]) { (finished) in
            completionHandler?(finished)
        }
    }
    
}

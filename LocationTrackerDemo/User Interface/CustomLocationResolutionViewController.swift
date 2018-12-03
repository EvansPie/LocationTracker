//
//  CustomLocationResolutionViewController.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 12/1/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import UIKit

class CustomLocationResolutionViewController: UIViewController {
    
    @IBOutlet weak var activityTypeTextField: UITextField!
    @IBOutlet weak var allowBackgroundLocationUpdatesSwitch: UISwitch!
    @IBOutlet weak var desiredAccuracyTextField: UITextField!
    @IBOutlet weak var distanceFilterTextField: UITextField!
    @IBOutlet weak var invalidTimestampTextField: UITextField!
    @IBOutlet weak var significantlyNewerTimeIntervalTextField: UITextField!
    @IBOutlet weak var significantDistanceChangeTextField: UITextField!
    @IBOutlet weak var significantAccuracyChangeTextField: UITextField!
    
    private var availableActivityTypes: [String] = ["Automotive navigation", "Other navigation", "Fitness", "Airborne", "Other"]
    private var activityType: CLActivityType?
    
    class func instantiate() -> CustomLocationResolutionViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomLocationResolutionViewController") as! CustomLocationResolutionViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(CustomLocationResolutionViewController.viewTapped))
        view.addGestureRecognizer(gr)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        activityTypeTextField.inputView = pickerView
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }

    @IBAction func doneButtontapped(_ sender: Any) {
        guard let activityType = activityType,
        let desiredAccuracyStr = desiredAccuracyTextField.text, let desiredAccuracy = Double(desiredAccuracyStr),
        let distanceFilterStr = distanceFilterTextField.text, let distanceFilter = Double(distanceFilterStr),
        let invalidTimestampStr = invalidTimestampTextField.text, let invalidTimestamp = Double(invalidTimestampStr),
        let significantlyNewerTimeIntervalStr = significantlyNewerTimeIntervalTextField.text, let significantlyNewerTimeInterval = Double(significantlyNewerTimeIntervalStr),
        let significantDistanceChangeStr = significantDistanceChangeTextField.text, let significantDistanceChange = Double(significantDistanceChangeStr),
        let significantAccuracyChangeStr = significantAccuracyChangeTextField.text, let significantAccuracyChange = Double(significantAccuracyChangeStr)
        else {
            let alert = UIAlertController(title: "", message: "Please complete all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let customResolution = LocationTracker.Resolution.custom(
            name: "custom",
            activityType: activityType,
            allowsBackgroundLocationUpdates: allowBackgroundLocationUpdatesSwitch.isOn,
            desiredAccuracy: desiredAccuracy,
            distanceFilter: distanceFilter,
            invalidTimestampAge: invalidTimestamp,
            significantlyNewerTimeInterval: significantlyNewerTimeInterval,
            significantDistanceChange: significantDistanceChange,
            significantAccuracyChange: significantAccuracyChange
        )
        LocationTracker.shared.resolution = customResolution
        navigationController?.popViewController(animated: true)
    }
}

extension CustomLocationResolutionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableActivityTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableActivityTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityTypeTextField.text = self.availableActivityTypes[row]
        switch self.availableActivityTypes[row] {
        case "Automotive navigation":
            activityType = .automotiveNavigation
        case "Other navigation":
            activityType = .otherNavigation
        case "Fitness":
            activityType = .fitness
        case "Airborne":
            activityType = .airborne
        case "Other":
            activityType = .other
        default:
            break
        }
    }
}

//
//  MenuViewController.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 11/2/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import MessageUI
import UIKit

class MenuViewController: UIViewController {

    // MARK: - OUTLETS & PROPERTIES
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var permissionButton: UIButton!
    @IBOutlet weak var locationUpdatesButton: UIButton!
    @IBOutlet weak var automaticResolutionChangeButton: UIButton!
    @IBOutlet weak var allowBackgroundLocationUpdatesButton: UIButton!
    @IBOutlet weak var currentResolutionLabel: UILabel!
    @IBOutlet weak var powerSaveSegmentedControl: UISegmentedControl!
    @IBOutlet weak var enforceLocationUpdateButton: UIButton!
    @IBOutlet weak var gpxRecordButton: UIButton!
    @IBOutlet weak var gpxExportButton: UIButton!
    @IBOutlet weak var debugRecordButton: UIButton!
    @IBOutlet weak var debugExportButton: UIButton!
    private var dummyTextField: UITextField!
    
    
    // MARK: - VIEW LIFE-CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.viewTapped))
        view.addGestureRecognizer(gr)
        
        dummyTextField = UITextField(frame: CGRect.zero)
        view.addSubview(dummyTextField)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        dummyTextField.inputView = pickerView
        
        let pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        pickerToolBar.barStyle = UIBarStyle.blackOpaque
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(MenuViewController.toolBardoneButtonTapped(_:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(MenuViewController.cancelButtonTapped(_:)))
        pickerToolBar.setItems([cancelButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        dummyTextField.inputAccessoryView = pickerToolBar
        
        activityIndicator.isHidden = true
        automaticResolutionChangeButton.tintColor = .clear
        enforceLocationUpdateButton.tintColor = .clear
        gpxRecordButton.tintColor = .clear
        
        render()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            self.render()
        }
    }
    
    private func render() {
        if LocationTracker.shared.hasPermission == true {
            permissionButton.isEnabled = false
            permissionButton.isSelected = false
            permissionButton.borderColor = .lightGray
        } else {
            permissionButton.isEnabled = true
            permissionButton.isSelected = false
            permissionButton.borderColor = .brightBlue
        }
        
        if LocationTracker.shared.hasPermission != true {
            locationUpdatesButton.isEnabled = false
            locationUpdatesButton.isSelected = false
            locationUpdatesButton.borderColor = .lightGray
        } else {
            locationUpdatesButton.isEnabled = true
            locationUpdatesButton.isSelected = LocationTracker.shared.isEnabled
            locationUpdatesButton.borderColor = locationUpdatesButton.isSelected ? .errorRed : .brightBlue
        }
        
        automaticResolutionChangeButton.isSelected = LocationTracker.shared.allowAutomaticResolutionChange
        automaticResolutionChangeButton.borderColor = automaticResolutionChangeButton.isSelected ? .errorRed : .brightBlue
        allowBackgroundLocationUpdatesButton.isSelected = LocationTracker.shared.allowBackgroundLocationUpdates
        allowBackgroundLocationUpdatesButton.borderColor = allowBackgroundLocationUpdatesButton.isSelected ? .errorRed : .brightBlue
        currentResolutionLabel.text = LocationTracker.shared.resolution.name
        powerSaveSegmentedControl.selectedSegmentIndex = LocationTracker.shared.powerSaveOption.rawValue
        enforceLocationUpdateButton.isSelected = activityIndicator.isAnimating
        enforceLocationUpdateButton.borderColor = enforceLocationUpdateButton.isSelected ? .errorRed : .brightBlue
        gpxRecordButton.isSelected = LocationTracker.shared.isGPXRecording
        gpxRecordButton.borderColor = gpxRecordButton.isSelected ? .errorRed : .brightBlue
        debugRecordButton.isSelected = LocationTracker.shared.isDebugRecording
        debugRecordButton.borderColor = debugRecordButton.isSelected ? .errorRed : .brightBlue
    }
    
    
    // MARK: - NOTIFICATION CENTER
    
    private func addNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.received(notification:)), name: Notification.Name.locationManagerDidChangeAuthStatus, object: nil)
    }
    
    @objc private func received(notification: Notification) {
        switch notification.name {
        case Notification.Name.locationManagerDidChangeAuthStatus:
            render()
        default:
            break
        }
    }
    
    // MARK: - ACTIONS
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func toolBardoneButtonTapped(_ sender: Any) {
        dummyTextField.resignFirstResponder()
    }
    
    @objc private func cancelButtonTapped(_ sender: Any) {
        dummyTextField.resignFirstResponder()
    }
    
    @IBAction func permissionButtonTapped(_ sender: Any) {
        switch LocationTracker.shared.hasPermission {
        case true?:
            break
        case false?:
            UIApplication.shared.openSettings { (completed) in
                
            }
        default:
            LocationTracker.shared.requestAuthorization(for: .authorizedWhenInUse)
        }
    }
    
    @IBAction func locationUpdatesButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        locationUpdatesButton.borderColor = sender.isSelected ? .errorRed : .brightBlue
        
        do {
            try LocationTracker.shared.enable(sender.isSelected)
        } catch {
            sender.isSelected = false
            sender.borderColor = sender.isSelected ? .errorRed : .brightBlue
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func allowBackgroundLocationUpdatesButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        LocationTracker.shared.allowBackgroundLocationUpdates = sender.isSelected
        render()
    }
    
    @IBAction func automaticResolutionButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.borderColor = sender.isSelected ? .errorRed : .brightBlue
        LocationTracker.shared.allowAutomaticResolutionChange = sender.isSelected
    }
    
    @IBAction func setResolutionButtonTapped(_ sender: UIButton) {
        if LocationTracker.shared.allowAutomaticResolutionChange {
            let alert = UIAlertController(title: "", message: "Setting a custom resolution will disable automatic resolution change. You can always set it up again. Continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { (_) in
                LocationTracker.shared.allowAutomaticResolutionChange = false
                self.render()
                self.dummyTextField.becomeFirstResponder()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            LocationTracker.shared.allowAutomaticResolutionChange = false
            self.render()
            self.dummyTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func powerSaveValueChanged(_ sender: UISegmentedControl) {
        LocationTracker.shared.powerSaveOption = LocationTracker.PowerSaveOption(rawValue: sender.selectedSegmentIndex)!
    }
    
    @IBAction func enforceLocationUpdateButtonTapped(_ sender: UIButton) {
        if activityIndicator.isAnimating { return }
        
        sender.isSelected = !sender.isSelected
        sender.borderColor = sender.isSelected ? .errorRed : .brightBlue
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        LocationTracker.shared.enforceLocationUpdate { [unowned self] (location, error) in
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "", message: "Location received successfully", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func gpxRecordingButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if LocationTracker.shared.recordedGPXLocations.count > 0 && sender.isSelected {
            let alert = UIAlertController(title: "", message: "Reset previously recorded GPX locations or add new updates on them?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (_) in
                LocationTracker.shared.recordedGPXLocations = []
                LocationTracker.shared.isGPXRecording = true
            }))
            alert.addAction(UIAlertAction(title: "Add", style: .cancel, handler: { (_) in
                LocationTracker.shared.isGPXRecording = true
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            LocationTracker.shared.isGPXRecording = sender.isSelected
        }
        
        render()
    }
    
    @IBAction func gpxExportButtonTapped(_ sender: UIButton) {
        if let url = LocationTracker.shared.generateGPX(locations: LocationTracker.shared.recordedGPXLocations) {
            if MFMailComposeViewController.canSendMail() {
                let now = Date()
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["evangelospittas@gmail.com"])
                mail.addAttachmentData(try! Data(contentsOf: url), mimeType: "text/plain", fileName: "route.gpx")
                mail.setSubject("GPX File | \(now.toString(format: "yyyy-MM-dd HH:mm.ss"))")
                mail.setMessageBody("Created by LocationTrackerDemo", isHTML: false)
                
                present(mail, animated: true)
            } else {
                // show failure alert
            }
        }
    }
    
    @IBAction func debugRecordingButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if LocationTracker.shared.recordedDebugLocations.count > 0 && sender.isSelected {
            let alert = UIAlertController(title: "", message: "Reset previously recorded debug locations or add new updates on them?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (_) in
                LocationTracker.shared.recordedDebugLocations = []
                LocationTracker.shared.isDebugRecording = true
            }))
            alert.addAction(UIAlertAction(title: "Add", style: .cancel, handler: { (_) in
                LocationTracker.shared.isDebugRecording = true
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            LocationTracker.shared.isDebugRecording = sender.isSelected
        }
        
        self.render()
    }
    
    @IBAction func debugExportButtonTapped(_ sender: Any) {
        if let url = LocationTracker.shared.generateDebugLocationsJSON(locations: LocationTracker.shared.recordedDebugLocations) {
            if MFMailComposeViewController.canSendMail() {
                let now = Date()
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["evangelospittas@gmail.com"])
                mail.addAttachmentData(try! Data(contentsOf: url), mimeType: "text/plain", fileName: "locations-debug.json")
                mail.setSubject("Locations Debug File | \(now.toString(format: "yyyy-MM-dd HH:mm.ss"))")
                mail.setMessageBody("Created by LocationTrackerDemo", isHTML: false)
                
                present(mail, animated: true)
            } else {
                // show failure alert
            }
        }
    }
    
}


extension MenuViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


extension MenuViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return LocationTracker.Resolution.idle(isBatterySavingEnabled: false).name
        case 1:
            return LocationTracker.Resolution.walk(isBatterySavingEnabled: false).name
        case 2:
            return LocationTracker.Resolution.jog(isBatterySavingEnabled: false).name
        case 3:
            return LocationTracker.Resolution.run(isBatterySavingEnabled: false).name
        case 4:
            return LocationTracker.Resolution.cycle(isBatterySavingEnabled: false).name
        case 5:
            return LocationTracker.Resolution.drive(isBatterySavingEnabled: false).name
        case 6:
            return LocationTracker.Resolution.speeding(isBatterySavingEnabled: false).name
        case 7:
            return "Custom"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            LocationTracker.shared.resolution = LocationTracker.Resolution.idle(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 1:
            LocationTracker.shared.resolution = LocationTracker.Resolution.walk(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 2:
            LocationTracker.shared.resolution = LocationTracker.Resolution.jog(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 3:
            LocationTracker.shared.resolution = LocationTracker.Resolution.run(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 4:
            LocationTracker.shared.resolution = LocationTracker.Resolution.cycle(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 5:
            LocationTracker.shared.resolution = LocationTracker.Resolution.run(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 6:
            LocationTracker.shared.resolution = LocationTracker.Resolution.speeding(isBatterySavingEnabled: LocationTracker.shared.isBatterySavingEnabled)
        case 7:
            let alert = UIAlertController(title: "", message: "Would you like to set a custom resolution now?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { (_) in
                let vc = CustomLocationResolutionViewController.instantiate()
                self.dummyTextField.resignFirstResponder()
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
                pickerView.selectRow(6, inComponent: 0, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
        
        render()
    }
    
}

//
//  MapViewController.swift
//  LocationTrackerDemo
//
//  Created by Vangelis Pittas on 10/31/18.
//  Copyright © 2018 Evangelos Pittas. All rights reserved.
//

import CoreLocation
import MapKit
import MessageUI
import UIKit

class MapViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.setTitle("Start recording", for: .normal)
        recordButton.setTitle("Stop recording", for: .selected)
        
        render()
        
        setupMapView()
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
            self.centerMap()
        }
    }
    
    private func render() {
        centerMap()
    }
    
    private func setupMapView() {
        mapView.showsUserLocation = true
    }
    
    func centerMap() {
        guard let coordinate = LocationTracker.shared.location?.coordinate else { return }
        let mapRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.region = mapRegion
    }

}

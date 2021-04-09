//
//  KRELocationManager.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 20/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreLocation

open class KRELocationManager: NSObject, CLLocationManagerDelegate {
    var lastKnowAccuracy: CGFloat = 0.0
    open var lastKnowRegion: KRERegion?
    
    // MARK: -
    public static let shared = KRELocationManager()
    public var locationManager: CLLocationManager?
    
    // MARK: -
    override init() {
        super.init()
    }
    
    public func setupLocationManager() {
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestAlwaysAuthorization()
        }
    }
    
    // MARK: -
    open func updateLastKnowLocation() {
        guard let locationManager = locationManager else {
            return
        }
        
        if lastKnowRegion == nil {
            lastKnowRegion = KRERegion(location: locationManager.location)
        } else {
            lastKnowRegion?.updateRegion(with: locationManager.location)
        }
    }
    
    func updateMonitoredRegions(forCurrentLocation currentLocation: KRERegion?) {
        updateLastKnowLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Location Services Status
        switch status {
        case .notDetermined, .restricted, .denied:
            guard let monitoredRegions = locationManager?.monitoredRegions else {
                return
            }
            
            for region in monitoredRegions {
                locationManager?.stopMonitoring(for: region)
            }
        case .authorizedAlways:
            updateMonitoredRegions(forCurrentLocation: lastKnowRegion)
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("KRELocationManager did failed update location : \(error)")
    }
}

// MARK: - KRERegion
open class KRERegion: NSObject {
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var radius: Double = 0.0
    public var isOutside = false
    public var accuracy: CLLocationAccuracy = 0
    
    // MARK: -
    init?(location: CLLocation?) {
        super.init()
        latitude = location?.coordinate.latitude ?? 0.0
        longitude = location?.coordinate.longitude ?? 0.0
        accuracy = location?.horizontalAccuracy ?? 0.0
        radius = accuracy
    }
    
    func updateRegion(with location: CLLocation?) {
        latitude = location?.coordinate.latitude ?? 0.0
        longitude = location?.coordinate.longitude ?? 0.0
        accuracy = location?.horizontalAccuracy ?? 0.0
        radius = accuracy
    }
}

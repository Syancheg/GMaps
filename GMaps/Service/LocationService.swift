//
//  LocationService.swift
//  GMaps
//
//  Created by Константин Кузнецов on 05.09.2021.
//

import Foundation
import CoreLocation
import RxSwift

final class LocationService: NSObject {
    
    let autorizationStatus: BehaviorSubject<CLAuthorizationStatus>
    let userLocation = PublishSubject<CLLocation>()
    private let locationManager = CLLocationManager()
    
    override init() {
        self.autorizationStatus = BehaviorSubject(value: locationManager.authorizationStatus)
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
    }

    func startUpdateLocation() {
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdateLocation() {
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func requestAuthorizationAccess() {
        locationManager.requestAlwaysAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        autorizationStatus.onNext(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation.onNext(location)
        }
    }
}

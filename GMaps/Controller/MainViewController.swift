//
//  MainViewController.swift
//  GMaps
//
//  Created by Константин Кузнецов on 21.08.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var pathButton: UIButton!
    
    private let locationManager = CLLocationManager()
    
    private var isTrackingPosition = false
    private var routeCoordinate = [CLLocationCoordinate2D]()
    private var route: GMSPolyline?
    private var routePath = GMSMutablePath()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setupLocationManager()
        setupButtons()
    }
    
    func checkLocationStatus(){
        
        let locationStatus = locationManager.authorizationStatus
        switch locationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("Location access denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func setupButtons(){
        trackButton.layer.cornerRadius = 10
        pathButton.layer.cornerRadius = 10
    }
    
    private func setupLocationManager(){
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: - Action
    
    
    @IBAction func trackAction(_ sender: Any) {
        
        checkLocationStatus()
        isTrackingPosition.toggle()
        let buttonTitle = isTrackingPosition ? "Закончить трек" : "Начать новый трек"
        let backgroundButton = isTrackingPosition ? UIColor.systemRed : UIColor.systemBlue
        trackButton.setTitle(buttonTitle, for: .normal)
        trackButton.backgroundColor = backgroundButton

        if isTrackingPosition {
            routePath.removeAllCoordinates()
            mapView.clear()
            setupRoute()
            locationManager.startUpdatingLocation()
        } else {
            savePath()
            mapView.clear()
            routePath.removeAllCoordinates()
            locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func viewPath(_ sender: Any) {
        if isTrackingPosition {
            alertTracking()
        } else {
            viewLastPath()
        }
    }
    
    // MARK: - Alert
    
    func alertTracking(){
        
        let alert = UIAlertController(title: "Внимание!", message: "Для отображения маршрута необходимо остановить слежение!", preferredStyle: .alert)
        let actionCansel = UIAlertAction(title: "Отмена", style: .cancel)
        let actionOk = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.trackButton.setTitle("Начать новый трек", for: .normal)
            strongSelf.trackButton.backgroundColor = .systemBlue
            strongSelf.isTrackingPosition = false
            strongSelf.locationManager.stopUpdatingLocation()
            strongSelf.mapView.clear()
            strongSelf.viewLastPath()
        }
        alert.addAction(actionCansel)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - RoutePath
    private func setupRoute(){
        
        route = GMSPolyline(path: routePath)
        route?.map = mapView
    }
    
    private func savePath(){
        
        let countDotRoute = routePath.count()
        for index in 0..<countDotRoute {
            routeCoordinate.append(routePath.coordinate(at: index))
        }
        let realmService = try! RealmService()
        realmService.removeCoordinate()
        realmService.putCoordinate(coordinates: routeCoordinate)
    }
    
    private func viewLastPath(){
        
        let realmService = try! RealmService()
        let coodinates = realmService.getCoodinate()
        routePath.removeAllCoordinates()
        for coordinate in coodinates {
            routePath.add(coordinate)
        }
        route = GMSPolyline(path: routePath)
        route?.map = mapView
        let bounds = GMSCoordinateBounds(path: routePath)
        let update = GMSCameraUpdate.fit(bounds)
        mapView.animate(with: update)
    }
}

    // MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let position = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
            mapView.animate(to: position)
            routePath.add(location.coordinate)
            route?.path = routePath
        }
    }
    
}

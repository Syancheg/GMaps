//
//  MainViewController.swift
//  GMaps
//
//  Created by Константин Кузнецов on 21.08.2021.
//

import UIKit
import GoogleMaps
import RxSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var pathButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    private let locationService = LocationService()
    private let disposeBag = DisposeBag()
    private let imageService = ImageService()
    
    
    private var isTrackingPosition = false
    private var routeCoordinate = [CLLocationCoordinate2D]()
    private var route: GMSPolyline?
    private var routePath = GMSMutablePath()
    private var userPhoto: UIImage?
    private var marker: GMSMarker?
    private var imagePickerView: UIImageView?
    private var avatarView:UIImageView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setupLocationManager()
        setupButtons()
        loadPhoto()
    }
    
    // MARK: - Setup
    
    private func setupButtons(){
        
        trackButton.layer.cornerRadius = 10
        pathButton.layer.cornerRadius = 10
        photoButton.layer.cornerRadius = 10
    }
    
    private func setupLocationManager(){

        locationService.autorizationStatus.subscribe(onNext: { [weak self] status in
            let locationStatus = status
            switch locationStatus {
            case .notDetermined:
                self?.locationService.requestAuthorizationAccess()
            case .restricted, .denied:
                print("Location access denied")
            case .authorizedAlways, .authorizedWhenInUse:
                self?.locationService.startUpdateLocation()
            @unknown default:
                break
            }
        })
        .disposed(by: disposeBag)
        locationService.userLocation.subscribe(onNext: { [weak self] location in
            self?.drawPath(location: location)
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    
    
    @IBAction func trackAction(_ sender: Any) {
        
        isTrackingPosition.toggle()
        let buttonTitle = isTrackingPosition ? "Закончить трек" : "Начать новый трек"
        let backgroundButton = isTrackingPosition ? UIColor.systemRed : UIColor.systemBlue
        trackButton.setTitle(buttonTitle, for: .normal)
        trackButton.backgroundColor = backgroundButton

        if isTrackingPosition {
            routePath.removeAllCoordinates()
            mapView.clear()
            setupRoute()
            locationService.startUpdateLocation()
        } else {
            savePath()
            mapView.clear()
            routePath.removeAllCoordinates()
            locationService.stopUpdateLocation()
        }
    }
    
    @IBAction func viewPath(_ sender: Any) {
        if isTrackingPosition {
            alertTracking()
        } else {
            viewLastPath()
        }
    }
    
    @IBAction func photoButtonAction(_ sender: UIButton) {
        
        viewPickerController()
    }
    
    // MARK: - Alert
    
    func alertTracking(){
        
        let alert = UIAlertController(title: "Внимание!", message: "Для отображения маршрута необходимо остановить слежение!", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
        let actionOk = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.trackButton.setTitle("Начать новый трек", for: .normal)
            strongSelf.trackButton.backgroundColor = .systemBlue
            strongSelf.isTrackingPosition = false
            strongSelf.locationService.stopUpdateLocation()
            strongSelf.mapView.clear()
            strongSelf.viewLastPath()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - RoutePath
    private func setupRoute(){
        
        route = GMSPolyline(path: routePath)
        route?.map = mapView
    }
    
    private func drawPath(location: CLLocation){
        let position = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
        mapView.animate(to: position)
        routePath.add(location.coordinate)
        route?.path = routePath
        addMarker(location: location)
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
    
    // MARK: - Avatar
    
    private func viewPickerController(){
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
    
    private func addMarker(location: CLLocation) {
        
        self.marker?.map = nil
        self.marker = nil
        if imagePickerView == nil {
            setupImageView()
        }
        let marker = GMSMarker(position: location.coordinate)
        marker.iconView = imagePickerView
        marker.map = mapView
        self.marker = marker
    }
    
    private func setupImageView(){
        
        if let image = userPhoto {
            let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
            let view = UIImageView(frame: rect)
            view.image = image
            view.layer.cornerRadius = 15
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1
            view.layer.masksToBounds = true
            imagePickerView = view
        }
    }

    private func loadPhoto(){
        
        if let image = imageService.getImage() {
            userPhoto = image
            viewPhoto()
        }
    }
    
    private func savePhoto(_ image: UIImage?){
        
        if image != nil {
            imageService.saveImage(image: image!)
        }
    }
    
    private func viewPhoto(){
    
        guard let image = userPhoto else { return }
        if avatarView == nil{
            let frame = CGRect(x: UIScreen.main.bounds.width - 110, y: 120, width: 80, height: 80)
            let imageView = UIImageView(frame: frame)
            imageView.image = image
            imageView.layer.cornerRadius = 40
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 3
            imageView.layer.masksToBounds = true
            avatarView = imageView
            view.addSubview(avatarView!)
        } else {
            avatarView!.image = image
        }
    }
}

extension MainViewController: UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = extractImage(from: info)
        savePhoto(image)
        imagePickerView = nil
        userPhoto = image
        viewPhoto()
        picker.dismiss(animated: true)
    }
    
}

extension MainViewController: UIImagePickerControllerDelegate {
    
}


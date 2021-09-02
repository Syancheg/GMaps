//
//  RealmService.swift
//  GMaps
//
//  Created by Константин Кузнецов on 27.08.2021.
//

import UIKit
import RealmSwift
import CoreLocation

public final class RealmService  {
    
    private let realm: Realm
    public convenience init() throws {
        try self.init(realm: Realm())
    }
    internal init(realm: Realm) {
        self.realm = realm
    }

    func putCoordinate(coordinates: [CLLocationCoordinate2D]){

        do {
            for coordinate in coordinates {
                let coordinateModel = Coordinate()
                coordinateModel.latitude  = coordinate.latitude
                coordinateModel.longitude = coordinate.longitude
                try realm.write{
                    realm.add(coordinateModel)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getCoodinate() -> [CLLocationCoordinate2D]{
        
        var returnCoordinate = [CLLocationCoordinate2D]()
        for coordinate in realm.objects(Coordinate.self) {
            var locationCoordinate = CLLocationCoordinate2D()
            locationCoordinate.latitude  = coordinate.latitude
            locationCoordinate.longitude = coordinate.longitude
            returnCoordinate.append(locationCoordinate)
        }
        return returnCoordinate
    }
    
    func removeCoordinate(){
        try! realm.write {
          realm.deleteAll()
        }
    }
    
}

//
//  Coordinate.swift
//  GMaps
//
//  Created by Константин Кузнецов on 27.08.2021.
//

import Foundation
import RealmSwift

class Coordinate: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
}

//
//  User.swift
//  GMaps
//
//  Created by Константин Кузнецов on 29.08.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    class override func primaryKey() -> String? {
        return "login"
    }
}

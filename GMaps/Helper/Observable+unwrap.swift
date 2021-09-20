//
//  Observable+unwrap.swift
//  GMaps
//
//  Created by Константин Кузнецов on 05.09.2021.
//

import Foundation
import RxSwift

extension Observable {
    
    func unwrap<T>() -> Observable<T> where Element == T? {
        self
            .filter{ $0 != nil }
            .map{ $0! }
    }
}

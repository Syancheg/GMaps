//
//  UIWindow+keyWindow.swift
//  GMaps
//
//  Created by Константин Кузнецов on 29.08.2021.
//

import UIKit

extension UIWindow {
    static var keyWindow: UIWindow? {
        
        if #available(iOS 13, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let delegate = windowScene.delegate as? SceneDelegate {
                return delegate.window
            }
        } else {
            return UIApplication.shared.keyWindow
        }
        return nil
    }
}

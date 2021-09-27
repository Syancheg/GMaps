//
//  ImageService.swift
//  GMaps
//
//  Created by Константин Кузнецов on 27.09.2021.
//

import Foundation
import UIKit

final class ImageService {
    
    func saveImage(image: UIImage){
        
        let png = image.pngData()
        UserDefaults.standard.set(png, forKey: "avatar")
    }
    
    func getImage() -> UIImage?{
        
        let imageData = UserDefaults.standard.object(forKey: "avatar") as? Data
        guard imageData != nil else { return nil }
        let image = UIImage(data: imageData!)
        return image
    }
}

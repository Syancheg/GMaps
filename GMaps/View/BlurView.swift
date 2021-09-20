//
//  BlurView.swift
//  GMaps
//
//  Created by Константин Кузнецов on 02.09.2021.
//

import UIKit

class BlurView: UIVisualEffectView {

    convenience init(){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        self.init(effect: blurEffect)
    }
    
    internal init(effect:UIBlurEffect){
        
        super.init(effect: effect)
        self.frame = UIScreen.main.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

}

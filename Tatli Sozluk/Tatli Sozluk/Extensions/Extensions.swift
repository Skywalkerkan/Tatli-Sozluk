//
//  Extensions.swift
//  Tatli Sozluk
//
//  Created by Erkan on 31.01.2023.
//

import Foundation
import UIKit

extension UIView{
    func klavyeAyarla(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(klavyeKonumAyarla(_ :)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        
    }
    
    @objc private func klavyeKonumAyarla(_ notification : NSNotification){   // klavyenin görüntüyü kapattığı içi görüntüyü kaydırma
        
        let sure = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        let baslangicFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let bitisFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let farkY = bitisFrame.origin.y - baslangicFrame.origin.y
        
        UIView.animateKeyframes(withDuration: sure, delay: 0.0, options: KeyframeAnimationOptions.init(rawValue: curve), animations: {
            self.frame.origin.y += farkY
        }, completion: nil)
        
        
    }
    
    
    
}

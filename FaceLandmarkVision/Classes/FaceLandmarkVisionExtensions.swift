//
//  FaceLandmarkVisionExtensions.swift
//  FaceLandmarkVision
//
//  Created by Nirzar Gandhi on 02/06/25.
//

import Foundation
import UIKit

// MARK: - UIViewController
extension UIViewController {
    
    // Add Navigation Bottom Shadow
    func hideNavigationBottomShadow() {
        
        self.navigationController?.navigationBar.layer.masksToBounds = true
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
    }
    
    // Get Top & Bottom bar height
    var getNavBarHeight: CGFloat {
        return (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var getTabBarHeight: CGFloat {
        return (self.tabBarController?.tabBar.frame.size.height ?? 49.0)
    }
    
    // Show Alert Message
    func showAlertMessage(titleStr: String, messageStr: String) {
        
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Camera Permission Denied Alert
    func cameraPermissionDeniedAlert() {
        
        let alertController = UIAlertController(title: "Camera Permission Denied",
                                                message: "Go to Settings > Privacy > Camera to allow access to your camera.",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { _ in
            
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(settingsAction)
        alertController.addAction(okayAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}



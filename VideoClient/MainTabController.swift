//
//  MainTabController.swift
//  VideoClient
//
//  Created by knax on 9/11/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import Foundation
import UIKit


//NavigationController
class MainTabController : UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        DispatchQueue.main.async {
            let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
            if item.tag == 0 {
                
                mainTabController.selectedViewController = mainTabController.viewControllers?[0]
                self.dismiss(animated: true, completion: nil)
            }
            
            if item.tag == 1 {
                mainTabController.selectedViewController = mainTabController.viewControllers?[1]
                self.dismiss(animated: true, completion: nil)
            }
            
            if item.tag == 2 {
                mainTabController.selectedViewController = mainTabController.viewControllers?[2]
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

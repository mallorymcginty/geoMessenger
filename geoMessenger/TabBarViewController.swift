//
//  TabBarViewController.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 3/26/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.tabBar.barTintColor = UIColor(red:0.70, green:0.97, blue:0.91, alpha:1.0)
        
        //convert hex value to UIColor
        //http://uicolor.xyz/#/hex-to-ui
        //equivalent to: #3498db?????
    }
    

   
}

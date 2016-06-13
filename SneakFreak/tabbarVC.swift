//
//  tabbarVC.swift
//  SneakFreak
//
//  Created by Reid on 3/1/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit

class tabbarVC: UITabBarController {

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()

        // font color
        self.tabBar.tintColor = .blackColor()
        
        // bar color
        self.tabBar.barTintColor = .whiteColor()
        
        self.tabBar.translucent = false
    }


}

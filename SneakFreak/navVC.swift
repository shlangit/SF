//
//  navVC.swift
//  SneakFreak
//
//  Created by Reid on 3/1/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit

class navVC: UINavigationController {

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()

        // color of title at the top in nav controller
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = .lightGrayColor()
        
        // color of background of nav controller
        self.navigationBar.barTintColor = UIColor.whiteColor()
        
        // disable translucent
        self.navigationBar.translucent = false
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!
        ]

        
    }

//    // change color of top color bar...
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }

}

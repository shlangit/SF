//
//  AppDelegate.swift
//  SneakFreak
//
//  Created by Reid on 2/18/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse
import Bolts


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        
        Parse.enableLocalDatastore()
        
        
//        // Initialize Parse.

        let configuration = ParseClientConfiguration {
            $0.applicationId = "o27NB6o7pYvwimp5GhDU2I3tryl1Ohvs60htRK66"
            $0.clientKey = "Vn5iBOC9bzNxWzuykipIbURx0DpnPvECRCXLi8yS"
            $0.server = "https://parseapi.back4app.com"
        }
        
        Parse.initializeWithConfiguration(configuration)

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // call login function
        login()
        
        
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            print("Object has been saved.")
//        }
        
        window?.backgroundColor = .whiteColor()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func login() {
        
        // Remeber Users Login
        let username: String? = NSUserDefaults.standardUserDefaults().stringForKey("username")
        
        // if logged in
        if username != nil {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! UITabBarController
            window?.rootViewController = myTabBar
        }
    }
    


}


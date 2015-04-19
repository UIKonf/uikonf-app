//
//  AppDelegate.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 14.02.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import UIKit
import Entitas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let context = Context()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let font = UIFont(name: "BauOT", size: 14)!
        let fontKey : NSString = NSFontAttributeName
        let attributes : [NSObject : AnyObject] = [fontKey : font]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState:UIControlState.Normal)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        syncData(context)
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
}


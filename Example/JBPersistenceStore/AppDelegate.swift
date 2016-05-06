//
//  AppDelegate.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 05/06/2016.
//  Copyright (c) 2016 Jan Bartel. All rights reserved.
//

import UIKit
import JBPersistenceStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let store = PersistenceStore(databaseFilename: "app")
        print(store)
        
        return true
    }


}


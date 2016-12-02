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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let store1 = PersistenceStore(databaseFilename: "app")

        let store2 = PersistenceStore(databaseFilename: "app2", version: 1) { (oldVersion: Int, newVersion:Int) in
            print("oldVersion: \(oldVersion) converted to newVersion:\(newVersion)")
        }

        print("The current version of store1 is \(store1.version())")
        print("The current version of store2 is \(store2.version())")

        return true
    }


}


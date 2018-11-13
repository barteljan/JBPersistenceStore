//
//  AppDelegate.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 05/06/2016.
//  Copyright (c) 2016 Jan Bartel. All rights reserved.
//

import JBPersistenceStore
import JBPersistenceStore_Protocols
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    let uniqueIdentifier = UUID().uuidString
    let uniqueIdentifiers = [UUID().uuidString, UUID().uuidString, UUID().uuidString]

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db" + UUID().uuidString, version: 0)

        self.demonstratePersistingMultipleItems(withStore: codingStore)
        self.demonstrateFetchtingMultipleItems(from: codingStore)

        self.demonstratePersistingSingleItem(withStore: codingStore)
        self.demonstrateFetchingSingleItem(from: codingStore)

        return true
    }

    func demonstratePersistingMultipleItems(withStore store: NSCodingPersistenceStore) {
        var multipleItems = [DemoModel]()

        for (index, identifier) in self.uniqueIdentifiers.enumerated() {
            multipleItems.append(DemoModel(modelId: identifier, modelName: "name number \(index)"))
        }

        try! store.persist(multipleItems)
    }

    func demonstrateFetchtingMultipleItems(from store: NSCodingPersistenceStore) {
        var multipleItems = [DemoModel]()
        try! multipleItems = store.getAll(DemoModel.self)

        /*
         in most cases you don't want all items, so you have to filter. It could be done like this:

         let yourChoice = multipleItems.filter { /* your magic here */ }
         */

        print("A list of all items that have been fetched:")

        for (index, item) in multipleItems.enumerated() {
            print("Item \(index), identifier \(item.modelId), name: \(item.modelName)")
        }
    }

    func demonstratePersistingSingleItem(withStore store: NSCodingPersistenceStore) {
        let demoModelToPersist = DemoModel(modelId: self.uniqueIdentifier, modelName: "the single model")
        try! store.persist(demoModelToPersist)
    }

    func demonstrateFetchingSingleItem(from store: NSCodingPersistenceStore) {
        let deSerializedModel = try! store.get(self.uniqueIdentifier, type: DemoModel.self)
        print("You have ordered the DemoModel with the uniqueIdentifier: \(self.uniqueIdentifier), here you are: \(deSerializedModel!.modelName)")
    }
}

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

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db" + UUID().uuidString, version: 0)

        self.demonstratePersistingMultipleItems(withStore: codingStore)
        self.demonstrateFetchtingMultipleItems(from: codingStore)

        self.demonstratePersistingSingleItem(withStore: codingStore)
        self.demonstrateFetchingSingleItem(from: codingStore)

        self.demonstrateCheckExistence(in: codingStore)
        
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

    func demonstrateCheckExistence(in store: NSCodingPersistenceStore) {
        let id = UUID().uuidString
        let itemFromSomewhere = DemoModel(modelId: id, modelName: "assume, this item is from an api ore somewhere else")
        
        let itemExits = try! store.exists(itemFromSomewhere)
        
        print("item is existing: \((itemExits ? "yes" : "no"))")
    }

    func demonstrateDeletingItem(fromStore store: NSCodingPersistenceStore) {
        // we create and persist an item first
        let id = UUID().uuidString
        let item = DemoModel(modelId: id, modelName: "Kurzlebiges Modell")
        try! store.persist(item)

        let itemToDelete = try! store.get(id, type: DemoModel.self)

        try! store.delete(itemToDelete)

        try! store.delete(itemToDelete) {
            print("maybe update UI?")
        }
    }
}

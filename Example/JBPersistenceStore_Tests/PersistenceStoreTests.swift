//
//  PersistenceStoreTests.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 12.05.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JBPersistenceStore
import JBPersistenceStore_Protocols

class PersistenceStoreTests: XCTestCase {
    
    func createStore() -> PersistenceStore{
        let uuid = NSUUID.init().uuidString
        let store = PersistenceStore(databaseFilename: uuid)
        return store
    }
    
    func testVersion() {
        let uuid = NSUUID.init().uuidString
        let store = PersistenceStore(databaseFilename: uuid, version : 2)
        let version = store.version()
        XCTAssert(version == 2)
    }
    
    
    func testVersionChangedHandlerDoesTriggerOnDatabaseVersionChange(){
        let oldVersion = 2
        let newVersion = 3
        let dbname = NSUUID.init().uuidString
        let exp = expectation(description: "wait for versionchangehandler")
        
        _ = PersistenceStore(databaseFilename: dbname, version: oldVersion) { (old:Int,new:Int) -> Void in }
        
        _ = PersistenceStore(databaseFilename: dbname, version: newVersion) { (old:Int,new:Int) -> Void in
            XCTAssert(old == oldVersion)
            XCTAssert(new == newVersion)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testVersionChangedHandlerDoesNotTriggerOnStableDatabaseVersion(){
        let uuid = UUID().uuidString
        let version = 2
        
        _ = PersistenceStore(databaseFilename: uuid, version : version, changeVersionHandler: {
            (from: Int, to: Int)in
            XCTFail("Should not fire on creation")
        })
        _ = PersistenceStore(databaseFilename: uuid, version : version, changeVersionHandler: {
            (from: Int, to: Int)in
            XCTFail("Should not fire on unchangedVersion")
        })
        
    }
    
    func testVersionChangeHandlerDoesntTriggerOnDatabaseCreation(){
        let uuid = UUID().uuidString
        let _ = PersistenceStore(databaseFilename: uuid, version : 2, changeVersionHandler: {
            (from: Int, to: Int)in
            XCTFail("Should not fire on creation")
        })
    }
    
    func testPersistence(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ =  store.persist(persistable)
        
        let persistable2 : TestPersistable? =  store.get("666")
        
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
        
    }
    
   
    
    
    func testDelete(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ =  store.persist(persistable)
        
        let persistable2 : TestPersistable? =  store.get("666")
        
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
        
        _ = store.delete(persistable)
        
        let persistable3 : TestPersistable? =  store.get("666")
        
        XCTAssertNil(persistable3)
        
    }
    
    
    func testGetByIdentifier(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ = store.persist(persistable)
        
        let persistable2 : TestPersistable? =  store.get("666")
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
    }
    
    
    func testGetByIdentifierAndType(){
      
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        _ = store.persist(persistable)
        
        let persistable2 = store.get("666", type: TestPersistable.self)
        XCTAssertNotNil(persistable2 as? TestPersistable)
        
        let converted = persistable2 as? TestPersistable
        
        XCTAssert(converted!.title == "Testtitel")
    }
    
    
    func testGetAllByType(){
        

        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ =  store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                           title: "Testtitel2")
        _ =  store.persist(persistable2)
        
        let items =  store.getAll(TestPersistable.self)
        
        XCTAssert(items.count == 2)
        
        let item667 = items.filter { (item:TestPersistable) -> Bool in
            return item.id == "667"
            }.first
        
        XCTAssertNotNil(item667)
        
    }
    
    
    func testExists(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ =  store.persist(persistable)
        
        let exists =  store.exists(persistable)
        XCTAssertTrue(exists)
            
        
    }
    
    
    
    func testExistsByIdentifier(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ = store.persist(persistable)
        
        let exists =  store.exists("666",type:TestPersistable.self)
        XCTAssertTrue(exists)
        
    }
    
    
    func testFilter(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ = store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                           title: "Testtitel2")
        _ = store.persist(persistable2)
        
        
        let item667 =  store.filter(TestPersistable.self, includeElement: { (item:TestPersistable) -> Bool in
            
            return item.id == "667"
        }).first
        
        XCTAssertNotNil(item667)
        
    }
    
    
    func addView(store: PersistenceStore) {
      
         store.addView("TestPersistablesByIdType",
                          groupingBlock: { (collection:String, key:String,
                            object: TestPersistable) -> String? in
                            
                            if Int(object.id) != nil{
                                return "isInt"
                            }else if (object.id == "isNotInView"){
                                return nil
                            }else{
                                return "isNotInt"
                            }
                            
                            
        }) { (group: String,
            collection1: String,
            key1: String,
            object1: TestPersistable,
            collection2: String,
            key2: String,
            object2: TestPersistable) -> ComparisonResult in
            
            return key1.compare(key2)
            
        }
       
    }
    
    func testAddView() {
        
        let store = self.createStore()
        
        self.addView(store: store)
        
    }
    
    
    func testGetAllFromView(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ = store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                           title: "Testtitel2")
        _ =  store.persist(persistable2)
        
        let persistable3 = TestPersistable(id: "Das ist keine Zahl",
                                           title: "Testtitel3")
        _ =  store.persist(persistable3)
        
        let persistable4 = TestPersistable(id: "isNotInView",
                                           title: "Testtitel4")
         _ = store.persist(persistable4)
         self.addView(store: store)
        
        let items: [TestPersistable] =  store.getAll("TestPersistablesByIdType")
        XCTAssert(items.count == 3)
        
    }
    
}

//
//  NSCodingPersitenceStoreTests.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 08.05.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JBPersistenceStore
import JBPersistenceStore_Protocols

class NSCodingPersitenceStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func createStore() -> NSCodingPersistenceStore{
        let uuid = NSUUID.init().uuidString
        let codingStore = NSCodingPersistenceStore(databaseFilename: uuid)
        return codingStore
    }
    
    func testVersion() {
        let uuid = NSUUID.init().uuidString
        let codingStore = NSCodingPersistenceStore(databaseFilename: uuid, version: 2) { (old:Int,new:Int) -> Void in }
        XCTAssert(codingStore.version() == 2)
    }
    
    
    func testIsResponsible() {
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Das müsste schon mit dem Teufel zugehen wenn das fehlschlägt")
        
        let responsible = store.isResponsible(for: persistable)
        XCTAssert(responsible)
    }
    
    func testIsNotResponsible() {
        let store = self.createStore()
        
        let responsible = store.isResponsible(for: "TestString")
        XCTAssertFalse(responsible)
    }
    
    func testIsResponsibleForType() {
        let store = self.createStore()
        
        
        let responsible = store.isResponsible(forType: TestPersistable.self)
        XCTAssert(responsible)
    }
    
    func testIsNotResponsibleForType() {
        let store = self.createStore()
        
        
        let responsible = store.isResponsible(forType: String.self)
        XCTAssertFalse(responsible)
    }
    
    func testPersistence(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        _ = try! store.persist(persistable)
        
        let persistable2 : TestPersistable? = try! store.get("666")
        
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
        
    }
    
    
    func testAsyncPersistence(){
    
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        
        let expect = expectation(description: "It should persist it")
        
        try! store.persist(persistable, completion: {
            let persistable2 : TestPersistable? = try! store.get("666")
            
            XCTAssertNotNil(persistable2)
            XCTAssert(persistable2!.title == "Testtitel")
            expect.fulfill()
            
        })
        
        
        waitForExpectations(timeout: 3) { (error: Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }
        
    }
    
    
    func testDelete(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 : TestPersistable? = try! store.get("666")
        
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
        
        try! store.delete(persistable)
        
        let persistable3 : TestPersistable? = try! store.get("666")
        
        XCTAssertNil(persistable3)
    
    }
    
    func testAsyncDelete(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 : TestPersistable? = try! store.get("666")
        
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
        
        
        let expect = expectation(description: "It should delete it")

        try! store.delete(persistable, completion: {
            let persistable3 : TestPersistable? = try! store.get("666")
            XCTAssertNil(persistable3)
            expect.fulfill()
        })
        
        
        waitForExpectations(timeout: 3) { (error: Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }
        
    }
    
    func testGetByIdentifier(){
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 : TestPersistable? = try! store.get("666")
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
    }
    
    
    func testAsyncGetByIdentifier(){
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let expect = expectation(description: "get async")
        
        try! store.get("666", completion: { (item: TestPersistable?) in
            XCTAssertNotNil(item)
            XCTAssert(item!.title == "Testtitel")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 3) { (error:Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }
        
    }
    
    func testGetByIdentifierAndType(){
    
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 = try! store.get("666", type: TestPersistable.self)
        XCTAssertNotNil(persistable2)
        XCTAssert(persistable2!.title == "Testtitel")
    }
    
    func testAsyncGetByIdentifierAndType(){
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let expect = expectation(description: "get async")
        
        try! store.get("666", type: TestPersistable.self, completion: { (item: TestPersistable?) in
            XCTAssertNotNil(item)
            XCTAssert(item!.title == "Testtitel")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 3) { (error:Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }

    }
    
    func testGetAllByType(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                          title: "Testtitel2")
        try! store.persist(persistable2)
        
        let items = try! store.getAll(TestPersistable.self)
        
        XCTAssert(items.count == 2)
        
        let item667 = items.filter { (item:TestPersistable) -> Bool in
            return item.id == "667"
        }.first
        
        XCTAssertNotNil(item667)
        
    }
    
    func testAsyncGetAllByType(){
    
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                           title: "Testtitel2")
        try! store.persist(persistable2)

        
        let expect = expectation(description: "get all async")
        
        try! store.getAll(TestPersistable.self, completion: { (items: [TestPersistable]) in
            
            XCTAssert(items.count == 2)
            
            let item667 = items.filter { (item:TestPersistable) -> Bool in
                return item.id == "667"
                }.first
            
            XCTAssertNotNil(item667)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 3) { (error:Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }
    }

    
    func testExists(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let exists = try! store.exists(persistable)
        XCTAssertTrue(exists)
        
    }
    
    
    func testAsyncExists(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let expect = expectation(description: "exists async")
        
        try! store.exists(persistable, completion: { (exists: Bool) in
            XCTAssertTrue(exists)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 3) { (error:Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }
        
    }
    
    func testExistsByIdentifier(){
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let exists = try! store.exists("666",type:TestPersistable.self)
        XCTAssertTrue(exists)
    }
    
    
    func testFilter(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                           title: "Testtitel2")
        try! store.persist(persistable2)
        
        
        let item667 = try! store.filter(TestPersistable.self, includeElement: { (item:TestPersistable) -> Bool in
    
            return item.id == "667"
        }).first
        
        XCTAssertNotNil(item667)

        
    }
    
    func testAsyncFiler(){
        
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Testtitel")
        
        try! store.persist(persistable)
        
        let persistable2 = TestPersistable(id: "667",
                                           title: "Testtitel2")
        try! store.persist(persistable2)
        
        
        let expect = expectation(description: "get all async")
        
        try! store.filter(TestPersistable.self,
                          includeElement: { (item:TestPersistable) -> Bool in
            
                            return item.id == "667"
            }, completion: { (items: [TestPersistable]) in
            
            let item667 = items.first
            XCTAssertNotNil(item667)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 3) { (error:Error?) in
            if let error = error {
                XCTFail("complete callback not called: \(error)")
            }
        }
    }

    
    func addView(store: NSCodingPersistenceStore) throws {
        
        try! store.addView("TestPersistablesByIdType",
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
        do {
            try self.addView(store: store)
        }   catch let error {
            XCTFail("FAIL: \(#file) \(#line) \(error)")
        }
    }
    
    
    func testGetAllFromView(){
        
        do {
            let store = self.createStore()
            
            let persistable = TestPersistable(id: "666",
                                              title: "Testtitel")
            
            try store.persist(persistable)
            
            let persistable2 = TestPersistable(id: "667",
                                               title: "Testtitel2")
            try store.persist(persistable2)
            
            let persistable3 = TestPersistable(id: "Das ist keine Zahl",
                                               title: "Testtitel3")
            try store.persist(persistable3)
            
            let persistable4 = TestPersistable(id: "isNotInView",
                                               title: "Testtitel4")
            try store.persist(persistable4)
            try self.addView(store: store)
            
            let items: [TestPersistable] = try store.getAll("TestPersistablesByIdType")
            XCTAssert(items.count == 3)
            
        }   catch let error {
            XCTFail("FAIL: \(#file) \(#line) \(error)")
        }

    }
    
    func testAsyncGetAllFromView(){
        
        do {
            let store = self.createStore()
            
            let persistable = TestPersistable(id: "666",
                                              title: "Testtitel")
            
            try store.persist(persistable)
            
            let persistable2 = TestPersistable(id: "667",
                                               title: "Testtitel2")
            try store.persist(persistable2)
            
            let persistable3 = TestPersistable(id: "Das ist keine Zahl",
                                               title: "Testtitel3")
            try store.persist(persistable3)
            
            let persistable4 = TestPersistable(id: "isNotInView",
                                               title: "Testtitel4")
            try store.persist(persistable4)
            try self.addView(store: store)
            
            let expect = expectation(description: "filter async")
            
            try store.getAll("TestPersistablesByIdType", completion: { (items: [TestPersistable]) in
                XCTAssert(items.count == 3)
                expect.fulfill()
            })
            
            waitForExpectations(timeout: 3) { (error:Error?) in
                if let error = error {
                    XCTFail("complete callback not called: \(error)")
                }
            }
            
            
        }   catch let error {
            XCTFail("FAIL: \(#file) \(#line) \(error)")
        }
        
    }

    
}

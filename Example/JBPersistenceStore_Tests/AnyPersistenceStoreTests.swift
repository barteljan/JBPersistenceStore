//
//  JBPersistenceStore_Tests.swift
//  JBPersistenceStore_Tests
//
//  Created by Jan Bartel on 08.05.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JBPersistenceStore
import JBPersistenceStore_Protocols
/*
class AnyPersistenceStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func createStore() -> AnyPersistenceStore{
        
        let store = AnyPersistenceStore(version: 0) { (old: Int, new: Int) in
            
        }
        
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db", version: 0)
        store.add(typedStore: codingStore)
        return store
    }
    
    func testVersion(){
        let store = AnyPersistenceStore(version: 3) { (old: Int, new: Int) in
            
        }

        XCTAssert(store.version() == 3)
    }
    
    func testIsResponsible() {
        let store = self.createStore()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Das müsste schon mit dem Teufel zugehen wenn das fehlschlägt")
        
        let responsible = store.isResponsible(for: persistable)
        XCTAssert(responsible)
    }
    
    func testIsResponsibleForType() {
        let store = self.createStore()
        
        
        let responsible = store.isResponsible(forType: TestPersistable.self)
        XCTAssert(responsible)
    }

    
    func testAdd() {
        let store = AnyPersistenceStore(version: 0) { (old: Int, new: Int) in
            
        }
        
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db", version: 0)
        store.add(typedStore: codingStore)
        
        XCTAssert(store.count() == 1)
    }
    
    
    
    
    
    
    
    
       
}
 
 */

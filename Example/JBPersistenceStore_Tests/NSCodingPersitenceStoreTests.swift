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
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db", version: 0)
        return codingStore
    }
    
    func testVersion() {
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db", version: 2)
        XCTAssertNotNil(codingStore)
        XCTAssert(codingStore.version() == 2)
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
    
    
}

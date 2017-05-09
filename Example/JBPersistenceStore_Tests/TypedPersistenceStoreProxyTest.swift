//
//  TypedPersistenceStoreProxy.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 08.05.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JBPersistenceStore_Protocols
import JBPersistenceStore

class TypedPersistenceStoreProxyTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /*
    func createStore() -> NSCodingPersistenceStore{
        let codingStore = NSCodingPersistenceStore(databaseFilename: "db", version: 0)
        return codingStore
    }
    
    func createProxy() -> TypedPersistenceStoreProxy{
        let store = self.createStore()
        let anyTypedStore = AnyTypedPersistenceStore(store)
        let proxy = TypedPersistenceStoreProxy(store: anyTypedStore)
        return proxy
    }
    
    func persistTestData(store: NSCodingPersistenceStore){
        
        let persistable1 = TestPersistable(id: "id_a", title: "Das ist der erste (a)")
        try! store.persist(persistable1)
        
        let persistable2 = TestPersistable(id: "id_b", title: "Das ist der zweite (b)")
        try! store.persist(persistable2)
    }
    
    func testIsResponsible() {
        let proxy = self.createProxy()
        
        let persistable = TestPersistable(id: "666",
                                          title: "Das müsste schon mit dem Teufel zugehen wenn das fehlschlägt")
        
        let responsible = proxy.isResponsible(persistable)
        XCTAssert(responsible)
    }
    
    func testIsResponsibleForType() {
        let proxy = self.createProxy()
        
        
        let responsible = proxy.isResponsibleForType(TestPersistable.self)
        XCTAssert(responsible)
    }
    
    func testPersistException(){
        
        let proxy = self.createProxy()
        
        //persisting a string should throw an error
        XCTAssertThrowsError( try proxy.persist("BAUM")) {(error: Error) in
            if let myError = error as? PersistenceStoreError  {
                
                switch (myError) {
                case .cannotUse:
                        break
                default:
                    XCTAssertTrue(false,"should throw a PersistenceStoreError.CannotUse when persisting a string")

                }
                
            }else {
                XCTAssertTrue(false,"should throw a PersistenceStoreError.CannotUse when persisting a string")
            }
        }
    }
    
    func testPersist(){
        
        let proxy = self.createProxy()
        let persistable3 = TestPersistable(id: "id_c", title: "Das ist der dritte (c)")
        try! proxy.persist(persistable3)
        
        
    }
     */
    
    
    
}

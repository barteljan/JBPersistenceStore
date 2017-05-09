//
//  PersistenceStoreServiceProviderTest.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 09.05.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JBPersistenceStore
import JBPersistenceStore_Protocols

class PersistenceStoreServiceProviderTest: XCTestCase {
    
    typealias StoreType = NSCoding & CanBePersistedProtocol
    
    func testGetService() {
        let serviceProvider = PersistenceStoreServiceProvider()
        
        let nsCodingPersistenceStore = NSCodingPersistenceStore(databaseFilename: "database", version: 0)
        
        let nsCodingPersistenceStoreService = NSCodingPersistenceStoreService(store: nsCodingPersistenceStore)
        
        serviceProvider.add(service: nsCodingPersistenceStoreService)
        
        //let object = TestPersistable(id: "15", title: "Der titel ist spannend")
        
        
        
        let store : AnyTypedPersistenceStore<StoreType>? = serviceProvider.store(forType: TestPersistable.self)
        
        XCTAssertNotNil(store)
        
        //let store2 = serviceProvider.store(for: object)
        
    }
    
    
}

//
//  PersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 27.03.16.
//
//
import JBPersistenceStore_Protocols
import YapDatabase
/*

@available(*, deprecated, message: "Doesn't throw any errors, has no async functions, use a AnyTypedPersistenceStore<NSCoding & CanBePersistedProtocol> store instead, NSCodingPersistenceStore could be a candidate")
open class PersistenceStore : PersistenceStoreProtocol {

    let store : NSCodingPersistenceStore
    
    public convenience init(databaseFilename: String){
        self.init(databaseFilename: databaseFilename, version : 0)
    }
    
    public convenience init(databaseFilename: String,
                            version : Int){
        self.init(databaseFilename: databaseFilename, version: version, changeVersionHandler: {(oldVersion: Int,newVerion: Int) -> Void in })
    }
    
    public convenience init(databaseFilename: String,
                         version: Int ,
            changeVersionHandler: ((Int,Int) -> Void)?){
        
        let store = NSCodingPersistenceStore(databaseFilename: databaseFilename,
                                                      version: version,
                                         changeVersionHandler: changeVersionHandler)
        
        
        
        self.init(store: store)
    }

    public init(store: NSCodingPersistenceStore) {
        self.store = store
    }
    
    public func version() -> Int{
        return self.store.version()
    }
    
    
    public func persist<T>(_ item: T) -> T where T: CanBePersistedProtocol, T: NSCoding {
        try! self.store.persist(item)
        return item
    }

    
    public func persist(_ item: CanBePersistedProtocol & NSCoding) -> CanBePersistedProtocol & NSCoding {
        try! self.store.persist(item)
        return item
    }
    
    public func delete<T>(_ identifier: String, type: T.Type) where T: CanBePersistedProtocol, T: NSCoding{
        try! self.store.delete(identifier, type: type)
    }
    
    public func delete(_ item: CanBePersistedProtocol) -> CanBePersistedProtocol {
        try! self.store.delete(item)
        return item
    }
    
    public func get<T>(_ identifier: String) -> T? where T: CanBePersistedProtocol, T: NSCoding {
        
        return try! self.store.get(identifier)
        
    }
    
    public func get(_ identifier: String, type: CanBePersistedProtocol.Type) -> CanBePersistedProtocol?{
        
        var item : CanBePersistedProtocol?

        let connection = self.store.readConnection
        connection.read { (transaction: YapDatabaseReadTransaction) in
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! CanBePersistedProtocol?
        }
                
        return item
    }
    
    
    public func exists<T>(_ item : T) -> Bool where T: CanBePersistedProtocol, T: NSCoding {
        return try! self.store.exists(item)
    }
    
    
    public func exists<T>(_ identifier : String,type : T.Type) -> Bool where T: CanBePersistedProtocol, T: NSCoding{
        return try! self.store.exists(identifier, type: type)
    }
    
    
    public func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) -> [T] where T: CanBePersistedProtocol, T: NSCoding {
        return try! self.store.filter(type, includeElement: includeElement)
    }
    
    
    public func addView<T>
        (     _ viewName: String,
              groupingBlock: @escaping ((_ collection: String,
        _ key: String,
        _ object: T)->String?),
              
              sortingBlock: @escaping ((     _ group: String,
        _ collection1: String,
        _ key1: String,
        _ object1: T,
        _ collection2: String,
        _ key2: String,
        _ object2: T) -> ComparisonResult)) where
    T: CanBePersistedProtocol,
        T: NSCoding {
            try! self.store.addView(viewName, groupingBlock: groupingBlock, sortingBlock: sortingBlock)
    }
    
    
    public func getAll<T>(_ type: T.Type) -> [T] where T: CanBePersistedProtocol, T: NSCoding {
        return try! self.store.getAll(type)
    }
    
    
    
    public func getAll<T>(_ viewName:String)->[T] where T: CanBePersistedProtocol, T: NSCoding {
        return try! self.store.getAll(viewName)
    }

    
    
    public func getAll<T>(_ viewName:String,groupName:String)->[T] where T: CanBePersistedProtocol, T: NSCoding {
        return try! self.store.getAll(viewName, groupName: groupName)
    }


}
*/

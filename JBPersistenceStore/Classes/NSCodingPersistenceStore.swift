//
//  NSCodingPersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 08.05.17.
//
//

import Foundation
import JBPersistenceStore_Protocols
import YapDatabase
import YapDatabase.YapDatabaseView

open class NSCodingPersistenceStore : TypedPersistenceStoreProtocol{
    
    public typealias PersistableType = NSCoding & CanBePersistedProtocol
    
    var database : YapDatabase
    internal let readConnection : YapDatabaseConnection
    internal let writeConnection : YapDatabaseConnection
    
    internal var _version : Int
    
    
    public convenience init(databaseFilename: String){
        self.init(databaseFilename: databaseFilename, version : 0)
    }
    
    public convenience init(databaseFilename: String, version : Int){
        self.init(databaseFilename: databaseFilename, version: version, changeVersionHandler: {(oldVersion: Int,newVerion: Int) -> Void in })
    }
    
    
    public init(databaseFilename: String, version newVersion: Int ,asyncChangeVersionHandler versionHandler:((NSCodingPersistenceStore,Int,Int,@escaping()->()) ->())){
        let databasePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(databaseFilename + ".sqlite").absoluteString
        
        
        let isExistingDatabase: Bool = (try? URL(string: databasePath)!.checkResourceIsReachable()) ?? false
        self.database = YapDatabase(path: databasePath)
        self.readConnection  = self.database.newConnection()
        self.writeConnection = self.database.newConnection()
        
        let userDefaultsKey = "\(databaseFilename)_JB_PERSISTENCE_STORE_DB_VERSION"
        
        let userDefaults = UserDefaults.standard
        let currentVersion: Int
        
        if isExistingDatabase{
            if let storedVersionObj = userDefaults.object(forKey: userDefaultsKey){
                if let storedVersion = storedVersionObj as? Int{
                    currentVersion = storedVersion
                }else{//invalid version number(should not happen)
                    userDefaults.removeObject(forKey: userDefaultsKey)
                    currentVersion = -1
                }
            }else{//forgot version number(unfortunately happened already)
                currentVersion = -1
            }
        }else{//new database
            self._version = newVersion
            userDefaults.set(self._version, forKey: userDefaultsKey)
            userDefaults.synchronize()
            return
        }
        
        //we have an existing database and a current version number at this point
        
        self._version = currentVersion
        
        let onSuccessfulChange = {
            DispatchQueue.main.async {
                self._version = newVersion
                userDefaults.set(self._version, forKey: userDefaultsKey)
                userDefaults.synchronize()
            }
        }
        
        if currentVersion != newVersion{
            versionHandler(self,currentVersion, newVersion, onSuccessfulChange)
        }
        
    }
    
    public convenience init(databaseFilename: String, version : Int ,changeVersionHandler: ((Int,Int) -> Void)?){
        self.init(databaseFilename: databaseFilename, version: version) { (oldStore,from, to, success) in
            changeVersionHandler?(from,to)
            success()
        }
    }

    public func version() -> Int{
        return self._version
    }
    
    public func isResponsible(for object: Any) -> Bool{
        return object is PersistableType
    }
    
    public func isResponsible(forType type: Any.Type) -> Bool{
        let result = type.self is PersistableType.Type
        return result
    }
    
    
    public func persist<T>(_ item: T!) throws {
        
        var error: Error?
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            do {
                let store = TransactionalNSCodingPersistenceStore(writeTransaction: transaction)
                try store.persist(item)
            } catch let thrownError {
                error = thrownError
            }
        }
    
        if let thrownError = error {
            throw thrownError
        }
    }
    
    public func persist<T>(_ item: T!,completion: @escaping () -> ()) throws {
        
        var error: Error?
        
        guard let _ = item as? PersistableType else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
        
        self.writeConnection.asyncReadWrite({ (transaction :YapDatabaseReadWriteTransaction) in
            do {
                let store = TransactionalNSCodingPersistenceStore(writeTransaction: transaction)
                try store.persist(item)
            } catch let thrownError {
                error = thrownError
            }
        }) {
            completion()
        }
        
        if let thrownError = error {
            throw thrownError
        }
    }
    
    public func delete<T>(_ item: T!) throws {
        
        var error: Error?
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            do {
                let store = TransactionalNSCodingPersistenceStore(writeTransaction: transaction)
                try store.delete(item)
            } catch let thrownError {
                error = thrownError
            }
        }
        
        if let thrownError = error {
            throw thrownError
        }

    }
        
    
    public func delete<T>(_ item: T!, completion: @escaping () -> ()) throws {
        
        guard let _ = item as? PersistableType else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
        
        var error: Error?
        
        self.writeConnection.asyncReadWrite({ (transaction:YapDatabaseReadWriteTransaction) in
            do {
                let store = TransactionalNSCodingPersistenceStore(writeTransaction: transaction)
                try store.delete(item)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion()
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
    }
    
    public func get<T>(_ identifier: String) throws -> T? {

        var error: Error?
        
        var item: T?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                item = try store.get(identifier)
            } catch let thrownError {
                error = thrownError
            }
        
        }

        if let thrownError = error {
            throw thrownError
        }
    
        return item
    }
    
    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws {
        
        guard let _ = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        var error: Error?
        var item: T?
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                item = try store.get(identifier)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion(item)
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
    }
    
    public func getAll<T>(_ type: T.Type) throws -> [T] {
        
        var error: Error?
        
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                items = try store.getAll(type)
            } catch let thrownError {
                error = thrownError
            }
            
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
        return items
    }
    
    public func getAll<T>(_ type: T.Type, completion: @escaping (_ items: [T]) -> Void) throws {
        
        guard let _ = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        var error: Error?
        
        var items : [T] = [T]()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                items = try store.getAll(type)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion(items)
        }
        
        if let thrownError = error {
            throw thrownError
        }

    }
    
    public func getAll<T>(_ viewName:String) throws ->[T] {
        
        var error: Error?
        
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                items = try store.getAll(viewName)
            } catch let thrownError {
                error = thrownError
            }
            
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
        return items
        
    }
    
    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        
        guard let _ = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        var error: Error?
        
        var items : [T] = [T]()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                items = try store.getAll(viewName)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion(items)
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws ->[T] {
        
        var error: Error?
        
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                items = try store.getAll(viewName,groupName:groupName)
            } catch let thrownError {
                error = thrownError
            }
            
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
        return items
    }
    
    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        
        guard let _ = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        var error: Error?
        
        var items : [T] = [T]()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                items = try store.getAll(viewName,groupName:groupName)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion(items)
        }
        
        if let thrownError = error {
            throw thrownError
        }
        

    }
    
    public func exists(_ item : Any!) throws -> Bool {
        
        var error: Error?
        
        var exists = false
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                exists = try store.exists(item)
            } catch let thrownError {
                error = thrownError
            }
            
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
        return exists
       
    }
    
    public func exists(_ item : Any!, completion: @escaping (_ exists: Bool) -> Void) throws  {
        
        var error: Error?
        
        var exists = false
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                exists = try store.exists(item)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion(exists)
        }
        
        if let thrownError = error {
            throw thrownError
        }
    }
    
    public func exists(_ identifier : String,type : Any.Type) throws -> Bool{
        
        var error: Error?
        
        var exists = false
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                exists = try store.exists(identifier,type: type)
            } catch let thrownError {
                error = thrownError
            }
            
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
        return exists
    }
    
    
    public func exists(_ identifier : String,type : Any.Type,  completion: @escaping (_ exists: Bool) -> Void) throws{
        
        
        var error: Error?
        
        var exists = false
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            do {
                let store = TransactionalNSCodingPersistenceStore(readTransaction: transaction)
                exists = try store.exists(identifier,type: type)
            } catch let thrownError {
                error = thrownError
            }
            
        }) {
            completion(exists)
        }
        
        if let thrownError = error {
            throw thrownError
        }

    }
    
    
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) throws  -> [T] {
        let list = try self.getAll(T.self)
        return list.filter(includeElement)
    }
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws {
        
        guard let _ = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        try self.getAll(T.self) { (items : [T]) in
            let filtered = items.filter(includeElement)
            completion(filtered)
        }
    }
    

    public func addView<T>(_ viewName: String, groupingBlock: @escaping ((String, String, T) -> String?), sortingBlock: @escaping ((String, String, String, T, String, String, T) -> ComparisonResult)) throws {
        
        if let _ = T.self as? PersistableType.Type {
        
            let grouping = YapDatabaseViewGrouping.withRowBlock { (transaction: YapDatabaseReadTransaction,
                collection:String,
                key:String,
                object:Any,
                metadata: Any?) -> String? in
                if(!(object is T)){
                    return nil
                }
                
                
                return groupingBlock(collection,key,object as! T)
            }
            
            let sorting = YapDatabaseViewSorting.withRowBlock { (transaction:  YapDatabaseReadTransaction,
                group:String,
                collection1: String,
                key1: String,
                object1:Any,
                metadata1:Any?,
                collection2:String,
                key2:String,
                object2:Any,
                metadata2:Any?) -> ComparisonResult in
                
                return sortingBlock(  group,
                                      collection1,
                                      key1,
                                      object1 as! T,
                                      collection2,
                                      key2,
                                      object2 as! T)
                
            }
            
            let view = YapDatabaseAutoView(grouping: grouping, sorting: sorting)
            self.database.register(view, withName: viewName)
            
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
    }
    
    public func transaction(transaction: @escaping (AnyTypedPersistenceStore<NSCoding & CanBePersistedProtocol>) throws -> Void) throws {
        
        var error: Error?
        
        self.writeConnection.readWrite { (myTransaction : YapDatabaseReadWriteTransaction) in
            
            
            do {
                let store = TransactionalNSCodingPersistenceStore(writeTransaction: myTransaction)
                let anyStore = AnyTypedPersistenceStore(store)
                try transaction(anyStore)
            } catch let thrownError {
                myTransaction.rollback()
                error = thrownError
            }
        }
        
        if let thrownError = error {
            throw thrownError
        }
        
    }
}

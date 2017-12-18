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
        
        if let item = item as? PersistableType {
            self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
                transaction.setObject(item, forKey: item.identifier(), inCollection: type(of: item).collectionName())
            }
        } else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
    
    }
    
    public func persist<T>(_ item: T!,completion: @escaping () -> ()) throws {
        
        if let item = item as? PersistableType {
        
            self.writeConnection.asyncReadWrite({ (transaction :YapDatabaseReadWriteTransaction) in
                transaction.setObject(item, forKey: item.identifier(), inCollection: type(of: item).collectionName())
            }) { 
                completion()
            }
            
        } else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
        
    }
    
    public func delete<T>(_ item: T!) throws {
        
        if let item = item as? PersistableType {
          
            let collection = type(of: item).collectionName()
            let identifier = item.identifier()
            
            self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
                transaction.removeObject(forKey: identifier, inCollection: collection)
            }
            
        } else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }

    }
        
    
    public func delete<T>(_ item: T!, completion: @escaping () -> ()) throws {
        
        if let item = item as? PersistableType {
            
            let collection = type(of: item).collectionName()
            let identifier = item.identifier()
            
            self.writeConnection.asyncReadWrite({ (transaction:YapDatabaseReadWriteTransaction) in
                
                transaction.removeObject(forKey: identifier, inCollection: collection)
                
            }) {
                completion()
            }
            
        } else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }

    }
    
    public func get<T>(_ identifier: String) throws -> T? {
        
        
        if let type = T.self as? PersistableType.Type {
            
            var item : T?
            
            self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
                item = transaction.object(forKey: identifier, inCollection: type.collectionName()) as! T?
            }
        
            return item
            
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }

    }
    
    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws {
        
        if let type = T.self as? PersistableType.Type {
            var item : T?
            
            self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
                
                item = transaction.object(forKey: identifier, inCollection: type.collectionName()) as! T?
                
            }) {
                completion(item)
            }
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
    }
    
    public func getAll<T>(_ type: T.Type) throws -> [T] {

        if let type = T.self as? PersistableType.Type {
            var items : [T] = [T]()
            
            let collection = type.collectionName()
            
            self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
                transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                    items.append(object as! T)
                })
            }
            
            return items
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
    }
    
    public func getAll<T>(_ type: T.Type, completion: @escaping (_ items: [T]) -> Void) throws {
        
        if let type = T.self as? PersistableType.Type {
            
            var items : [T] = [T]()
            
            let collection = type.collectionName()
            
            self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
                
                transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                    items.append(object as! T)
                })
                
            }) {
                completion(items)
            }
            
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }

    }
    
    public func getAll<T>(_ viewName:String) throws ->[T] {
        
        if let _ = T.self as? PersistableType.Type {
        
            var resultArray : Array<T> = [T]()
            
            self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
                if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                    viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                        viewTransaction.enumerateKeysAndObjects(inGroup: group, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                            resultArray.append(object as! T)
                        })
                    })
                }
            }
            
            return resultArray
            
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
    }
    
    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        
        if let _ = T.self as? PersistableType.Type {
        
            var resultArray : [T] = [T]()
            
            self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
                if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                    viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                        viewTransaction.enumerateKeysAndObjects(inGroup: group, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                            resultArray.append(object as! T)
                        })
                    })
                }
            }) {
                completion(resultArray)
            }
            
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }


        
    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws ->[T] {
        
        if let _ = T.self as? PersistableType.Type {
            var resultArray = [T]()
            
            self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
                
                if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                    viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with:[], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        
                        resultArray.append(object as! T)
                    })
                }
                
            }
            return resultArray
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
    }
    
    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        
        if let _ = T.self as? PersistableType.Type {
            var resultArray : [T] = [T]()
    
            self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
                
                if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                    viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with:[], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        
                        resultArray.append(object as! T)
                    })
                }
                
            }) {
                completion(resultArray)
            }
            
        } else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        

    }
    
    public func exists(_ item : Any!) throws -> Bool {
        
        if(!self.isResponsible(for: item)){
            return false
        }
        
        var exists : Bool = false
        
        if let myItem = item as? PersistableType {
            let collection = type(of: myItem.self).collectionName()
            let identifier = myItem.identifier()
            
            self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
                
                exists = transaction.hasObject(forKey: identifier, inCollection: collection)

            }
        }
        
       
        return exists
       
    }
    
    public func exists(_ item : Any!, completion: @escaping (_ exists: Bool) -> Void) throws  {
        
        if(!self.isResponsible(for: item)){
            completion(false)
            return
        }
        
        if let myItem = item as? PersistableType {
            
            let collection = type(of: myItem.self).collectionName()
            let identifier = myItem.identifier()
            
            var exists : Bool = false
            
            self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
                exists = transaction.hasObject(forKey: identifier, inCollection: collection)
            }, completionBlock: {
                completion(exists)
            })
            
        } else {
            completion(false)
        }

    }
    
    public func exists(_ identifier : String,type : Any.Type) throws -> Bool{
        if(!self.isResponsible(forType: type)){
            return false
        }
        
        var exists : Bool = false
        
        if let myType = type.self as? PersistableType.Type{
            let collection = myType.collectionName()
            
            self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
                
                exists = transaction.hasObject(forKey: identifier, inCollection: collection)
                
            }
        }
        
        return exists
    }
    
    
    public func exists(_ identifier : String,type : Any.Type,  completion: @escaping (_ exists: Bool) -> Void) throws{
        
        if(!self.isResponsible(forType: type)){
            completion(false)
            return
        }
        
        var exists : Bool = false
        
        if let myType = type.self as? PersistableType.Type{
            let collection = myType.collectionName()
        
            self.readConnection.asyncRead({ (transaction: YapDatabaseReadTransaction) in
                exists = transaction.hasObject(forKey: identifier, inCollection: collection)
            
            }) {
                completion(exists)
            }
        }else{
            completion(false)
        }

        
    }
    
    
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) throws  -> [T] {
        let list = try self.getAll(T.self)
        return list.filter(includeElement)
    }
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws {
        
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
    
    public func transaction(transaction: @escaping (AnyTypedPersistenceStore<NSCoding & CanBePersistedProtocol>) throws -> Void) rethrows {
        
    }
}

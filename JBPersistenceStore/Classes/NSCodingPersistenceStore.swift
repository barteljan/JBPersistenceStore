//
//  NSCodingPersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 08.05.17.
//
//

import Foundation
import JBPersistenceStore_Protocols
import Foundation
import YapDatabase
import YapDatabase.YapDatabaseView

open class NSCodingPersistenceStore : TypedPersistenceStoreProtocol{
        
    public typealias PersistableType = NSCoding & CanBePersistedProtocol
    
    var database : YapDatabase
    internal let readConnection : YapDatabaseConnection
    internal let writeConnection : YapDatabaseConnection
    
    internal var _version : Int
    internal var changeVersionHandler : ((Int,Int) -> Void)!
    
    
    public convenience init(databaseFilename: String){
        self.init(databaseFilename: databaseFilename, version : 0)
    }
    
    public convenience init(databaseFilename: String, version : Int){
        self.init(databaseFilename: databaseFilename, version: version, changeVersionHandler: {(oldVersion: Int,newVerion: Int) -> Void in })
    }
    
    public init(databaseFilename: String, version : Int ,changeVersionHandler: ((Int,Int) -> Void)?){
        let databasePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(databaseFilename + ".sqlite").absoluteString
        
        self.database = YapDatabase(path: databasePath)
        self.readConnection  = self.database.newConnection()
        self.writeConnection = self.database.newConnection()
        
        if let versionHandler = changeVersionHandler{
            self.changeVersionHandler = versionHandler
        }else{
            self.changeVersionHandler = {(oldVersion: Int,newVerion: Int) -> Void in }
        }
        
        self._version = version
        
        var userDefaultsKey = "\(databaseFilename)_JB_PERSISTENCE_STORE_DB_VERSION"
        
        let userDefaults = UserDefaults.standard
        
        var oldVersion : Int = userDefaults.integer(forKey: userDefaultsKey)
        
        if(self._version != oldVersion){
            userDefaults.set(self._version, forKey: userDefaultsKey)
            userDefaults.synchronize()
            self.changeVersionHandler(oldVersion,self._version)
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
    
    
    public func persist<T>(_ item: T!) throws where T : PersistableType {
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.setObject(item, forKey: item.identifier(), inCollection: T.collectionName())
        }
    
    }
    
    public func persist<T>(_ item: T!,completion: @escaping () -> ()) throws where T : PersistableType {
        
        self.writeConnection.asyncReadWrite({ (transaction :YapDatabaseReadWriteTransaction) in
            transaction.setObject(item, forKey: item.identifier(), inCollection: T.collectionName())
        }) { 
            completion()
        }
        
    }
    
    public func delete<T>(_ item: T!) throws where T : PersistableType {
        let collection = type(of: item!.self).collectionName()
        let identifier = item.identifier()
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObject(forKey: identifier, inCollection: collection)
        }

    }
        
    
    public func delete<T>(_ item: T!, completion: @escaping () -> ()) throws where T : PersistableType{
        let collection = type(of: item!.self).collectionName()
        let identifier = item.identifier()
        
        self.writeConnection.asyncReadWrite({ (transaction:YapDatabaseReadWriteTransaction) in
            
            transaction.removeObject(forKey: identifier, inCollection: collection)
            
        }) {
            completion()
        }

    }
    
    public func get<T>(_ identifier: String) throws -> T? where T : PersistableType {
        
        var item : T?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            item = transaction.object(forKey: identifier, inCollection: T.collectionName()) as! T?
        }
        
        return item

    }
    
    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws where T : PersistableType {
        
        var item : T?
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            item = transaction.object(forKey: identifier, inCollection: T.collectionName()) as! T?
            
        }) {
            completion(item)
        }
        
    }
    
    public func get<T>(_ identifier: String, type: T.Type) throws -> T? where T : PersistableType {
        
        var item : T?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! T?
        }
        
        return item
        
    }
    
    public func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws where T : PersistableType {
        
        var item : T?
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! T?
            
        }) {
            completion(item)
        }

    }
    
    public func getAll<T>(_ type: T.Type) throws -> [T] where T : PersistableType {

        var items : [T] = [T]()
        
        let collection = type.collectionName()
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                items.append(object as! T)
            })
        }
        
        return items
    }
    
    public func getAll<T>(_ type: T.Type, completion: @escaping (_ items: [T]) -> Void) throws where T : PersistableType {
        
        var items : [T] = [T]()
        
        let collection = type.collectionName()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                items.append(object as! T)
            })
            
        }) {
            completion(items)
        }

    }
    
    public func getAll<T>(_ viewName:String) throws ->[T] where T : PersistableType {
        
        var resultArray : Array<T> = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as! YapDatabaseViewTransaction
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                    viewTransaction.enumerateKeysAndObjects(inGroup: group, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        resultArray.append(object as! T)
                    })
                })
            }
        }
        
        return resultArray
        
    }
    
    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws where T : PersistableType {
        
        var resultArray : [T] = [T]()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as! YapDatabaseViewTransaction
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

        
    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws ->[T] where T : PersistableType {
        
        var resultArray = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with:[], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                    
                    resultArray.append(object as! T)
                })
            }
            
        }
        
        return resultArray
    }
    
    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws where T : PersistableType {
        
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
    
    
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) throws  -> [T]  where T : PersistableType {
        let list = try self.getAll(T.self)
        return list.filter(includeElement)
    }
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws where T : PersistableType {
        
        try self.getAll(T.self) { (items : [T]) in
            let filtered = items.filter(includeElement)
            completion(filtered)
        }
    }
    

    public func addView<T>(_ viewName: String, groupingBlock: @escaping ((String, String, T) -> String?), sortingBlock: @escaping ((String, String, String, T, String, String, T) -> ComparisonResult)) throws {
        
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
        
        let view = YapDatabaseView(grouping: grouping, sorting: sorting)
        
        self.database.register(view, withName: viewName)
        
    }
}

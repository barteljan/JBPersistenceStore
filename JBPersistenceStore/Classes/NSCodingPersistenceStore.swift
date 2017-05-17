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
    
    
    public func persist(_ item: PersistableType) throws {
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.setObject(item, forKey: item.identifier(), inCollection: type(of: item).collectionName())
        }
        
    }
    
    public func persist(_ item: PersistableType,completion: @escaping () -> ()) throws {
        
        self.writeConnection.asyncReadWrite({ (transaction :YapDatabaseReadWriteTransaction) in
            transaction.setObject(item, forKey: item.identifier(), inCollection: type(of: item).collectionName())
        }) { 
            completion()
        }
        
    }
    
    public func delete(_ item: PersistableType) throws {
        
        let collection = type(of: item).collectionName()
        let identifier = item.identifier()
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObject(forKey: identifier, inCollection: collection)
        }
        
    }
        
    
    public func delete(_ item: PersistableType, completion: @escaping () -> ()) throws {
        
        let collection = type(of: item).collectionName()
        let identifier = item.identifier()
            
        self.writeConnection.asyncReadWrite({ (transaction:YapDatabaseReadWriteTransaction) in
            
            transaction.removeObject(forKey: identifier, inCollection: collection)
            
        }) {
            completion()
        }
    }
    
    /*
    public func delete(_ identifier: String, type: PersistableType.Protocol) throws {
        
    }
    */

    public func delete(_ identifier: String, type: PersistableType.Protocol) throws {
        
        let collection = type(of:type).collectionName()
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObject(forKey: identifier, inCollection: collection)
        }
        
    }
    
    public func delete(_ identifier: String, type: PersistableType.Type, completion: @escaping () -> ()) throws {
        
        let collection = type.collectionName()
    
        self.writeConnection.asyncReadWrite({ (transaction:YapDatabaseReadWriteTransaction) in
            
            transaction.removeObject(forKey: identifier, inCollection: collection)
            
        }) {
            completion()
        }
       
    }
    
    
    public func get(_ identifier: String, type: PersistableType.Type) throws -> PersistableType? {
        
        var item : PersistableType?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! PersistableType?
        }
        
        return item
        
    }
    
    public func get(_ identifier: String, type: PersistableType.Type, completion: @escaping (_ item: PersistableType?) -> Void ) throws {
        
        var item : PersistableType?
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! PersistableType?
            
        }) {
            completion(item)
        }
    }
    
    public func getAll(_ type: PersistableType.Type) throws -> [PersistableType] {

        var items : [PersistableType] = [PersistableType]()
        
        let collection = type.collectionName()
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                items.append(object as! PersistableType)
            })
        }
        
        return items
        
    }
    
    public func getAll(_ type: PersistableType.Type, completion: @escaping (_ items: [PersistableType]) -> Void) throws {
        
        var items : [PersistableType] = [PersistableType]()
        
        let collection = type.collectionName()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                items.append(object as! PersistableType)
            })
            
        }) {
            completion(items)
        }
        
    }
    
    public func getAll(_ viewName:String) throws ->[PersistableType] {
        
        var resultArray = [PersistableType]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as! YapDatabaseViewTransaction
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                    viewTransaction.enumerateKeysAndObjects(inGroup: group, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        resultArray.append(object as! PersistableType)
                    })
                })
            }
        }
        
        return resultArray
        
    }
    
    public func getAll(_ viewName:String, completion: @escaping (_ items: [PersistableType]) -> Void) throws {
        
        var resultArray = [PersistableType]()
        
        self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
            
            let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as! YapDatabaseViewTransaction
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                    viewTransaction.enumerateKeysAndObjects(inGroup: group, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        resultArray.append(object as! PersistableType)
                    })
                })
            }
            
        }) {
            completion(resultArray)
        }
    }
    
    public func getAll(_ viewName:String,groupName:String) throws ->[PersistableType] {
        
        var resultArray = [PersistableType]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with:[], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                    
                    resultArray.append(object as! PersistableType)
                })
            }
            
        }
        
        return resultArray
    }
    
    public func getAll(_ viewName:String,groupName:String, completion: @escaping (_ items: [PersistableType]) -> Void) throws {
        
            var resultArray = [PersistableType]()
            
            self.readConnection.asyncRead({ (transaction:YapDatabaseReadTransaction) in
                
                if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                    viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with:[], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        
                        resultArray.append(object as! PersistableType)
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
    
    
    
    public func filter(_ type: PersistableType.Type, includeElement: @escaping (PersistableType) -> Bool) throws  -> [PersistableType] {
        let list = try self.getAll(PersistableType.self)
        return list.filter(includeElement)
    }
    
    public func filter(_ type: PersistableType.Type, includeElement: @escaping (PersistableType) -> Bool, completion: @escaping (_ items: [PersistableType]) -> Void) throws {
        
        try self.getAll(PersistableType.self) { (items : [PersistableType]) in
            let filtered = items.filter(includeElement)
            completion(filtered)
        }
    }
    

    public func addView(_ viewName: String, groupingBlock: @escaping ((String, String, PersistableType) -> String?), sortingBlock: @escaping ((String, String, String, PersistableType, String, String, PersistableType) -> ComparisonResult)) throws {
        
        let grouping = YapDatabaseViewGrouping.withRowBlock { (transaction: YapDatabaseReadTransaction,
            collection:String,
            key:String,
            object:Any,
            metadata: Any?) -> String? in
            if(!(object is PersistableType)){
                return nil
            }
            
            
            return groupingBlock(collection,key,object as! PersistableType)
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
                                  object1 as! PersistableType,
                                  collection2,
                                  key2,
                                  object2 as! PersistableType)
            
        }
        
        let view = YapDatabaseView(grouping: grouping, sorting: sorting)
        
        self.database.register(view, withName: viewName)
            
    }
}

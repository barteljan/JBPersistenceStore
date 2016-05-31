//
//  DataBaseStore.swift
//  Pods
//
//  Created by Jan Bartel on 27.03.16.
//
//

import Foundation
import YapDatabase
import ValueCoding
import YapDatabase.YapDatabaseView
import JBPersistenceStore_Protocols



public class PersistenceStore : PersistenceStoreProtocol{
    
    var database : YapDatabase
    internal let readConnection : YapDatabaseConnection
    internal let writeConnection : YapDatabaseConnection
    
    public init(databaseFilename: String){
        let databasePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(databaseFilename + ".sqlite").absoluteString
        
        self.database = YapDatabase(path: databasePath)
        self.readConnection  = self.database.newConnection()
        self.writeConnection = self.database.newConnection()
    }
    
    
    public func persist<
        T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(item: T) -> T {
        
        self.writeConnection.readWriteWithBlock { (transaction : YapDatabaseReadWriteTransaction) in
            let coder = T.Coder(item)
            transaction.setObject(coder, forKey: item.identifier(), inCollection: T.collectionName())
        }
        
        return item
    }
    
    
    public func persist<
        T where
        T: CanBePersistedProtocol,
        T: NSCoding>(item: T) -> T {
        
        self.writeConnection.readWriteWithBlock { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.setObject(item, forKey: item.identifier(), inCollection: T.collectionName())
        }
        
        return item
    }
    
    
    public func persist(item: protocol<CanBePersistedProtocol,NSCoding>) -> protocol<CanBePersistedProtocol,NSCoding> {
    
        self.writeConnection.readWriteWithBlock { (transaction : YapDatabaseReadWriteTransaction) in
            let collection = item.self.dynamicType.collectionName()
            transaction.setObject(item, forKey: item.identifier(), inCollection: collection)
        }
        
        return item
        
    }
    
    public func delete<
        T where
        T: CanBePersistedProtocol,
        T: NSCoding>(identifier: String, type: T.Type){
        
        let collection = type.collectionName()
        
        self.writeConnection.readWriteWithBlock { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObjectForKey(identifier, inCollection: collection)
        }
    }
    
    public func delete(item: CanBePersistedProtocol) -> CanBePersistedProtocol{
        let collection = item.self.dynamicType.collectionName()
        let identifier = item.identifier()
        
        self.writeConnection.readWriteWithBlock { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObjectForKey(identifier, inCollection: collection)
        }
        
        return item
    }
    
    public func get<
        T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(identifier: String) -> T?{
        
        var item : T?
        
        self.readConnection.readWithBlock { (transaction: YapDatabaseReadTransaction) in
            
            let coder = transaction.objectForKey(identifier, inCollection: T.collectionName()) as! T.Coder
            item = coder.value
            
        }
        
        return item
    }
    
    
    public func get<
        T where
        T: CanBePersistedProtocol,
        T: NSCoding>(identifier: String) -> T?{
        
        var item : T?
        
        self.readConnection.readWithBlock { (transaction: YapDatabaseReadTransaction) in
            item = transaction.objectForKey(identifier, inCollection: T.collectionName()) as! T?
        }
        
        return item

    
    }
    
    public func get(identifier: String, type: CanBePersistedProtocol.Type) -> CanBePersistedProtocol?
    {
        
        var item : CanBePersistedProtocol?
        
        self.readConnection.readWithBlock { (transaction: YapDatabaseReadTransaction) in
            let collectionName = type.collectionName()
            item = transaction.objectForKey(identifier, inCollection:collectionName) as! CanBePersistedProtocol?
        }
        
        return item
        
    }

    

    public func exists<T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(item : T) -> Bool{
        
        let identifier = item.identifier()
        let collection = T.collectionName()
        
        var exists  = false
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObjectForKey(identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    }
    
    
    
    public func exists<T where
        T: CanBePersistedProtocol,
        T: NSCoding>(item : T) -> Bool{
    
        let identifier = item.identifier()
        let collection = T.collectionName()
        
        var exists  = false
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObjectForKey(identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    }
    
    
    public func exists<T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(identifier : String,type : T.Type) -> Bool{
        
        let identifier = identifier
        let collection = type.collectionName()
        
        var exists  = false
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObjectForKey(identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    
    }
    
    
    public func exists<T where
        T: CanBePersistedProtocol,
        T: NSCoding>(identifier : String,type : T.Type) -> Bool{
        
        let identifier = identifier
        let collection = type.collectionName()
        
        var exists  = false
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObjectForKey(identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    }

    
    
    public func getAll<
        T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(type: T.Type) -> [T]{
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            transaction.enumerateRowsInCollection(collection, usingBlock: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                let coder = object as! T.Coder
                items.append(coder.value as! T)
            })
        }
        
        return items
    }
    
    
    public func getAll<
        T where
        T: CanBePersistedProtocol,
        T: NSCoding>(type: T.Type) -> [T]{
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            transaction.enumerateRowsInCollection(collection, usingBlock: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                items.append(object as! T)
            })
        }
        print(items)
        return items
    }

    
    
    public func filter <T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(type: T.Type, includeElement: (T) -> Bool) -> [T]{
        
        let collection = type.collectionName()
    
        var items : [T] = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            
            transaction.enumerateRowsInCollection(collection, usingBlock: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                let coder = object as! T.Coder
                if(includeElement(coder.value)){
                    items.append(coder.value as! T)
                }
            })
        
        }
        
        return items
    
    }
    
    
    public func filter <T where
        T: CanBePersistedProtocol,
        T: NSCoding>(type: T.Type, includeElement: (T) -> Bool) -> [T]{
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            
            transaction.enumerateRowsInCollection(collection, usingBlock: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                if(includeElement(object as! T)){
                    items.append(object as! T)
                }
            })
            
        }
        
        return items
        
    }

    
    
    public func addView<T where
                        T: CanBePersistedProtocol,
                        T: ValueCoding,
                        T.Coder: NSCoding,
                        T.Coder.ValueType == T>
                        (     viewName: String,
                              
                              groupingBlock:((  collection: String,
                                                       key: String,
                                                    object: T)->String?),
                              
                              sortingBlock: ((     group: String,
                                             collection1: String,
                                                    key1: String,
                                                 object1: T,
                                             collection2: String,
                                                    key2: String,
                                                 object2: T) -> NSComparisonResult)){
        
        
        let grouping = YapDatabaseViewGrouping.withRowBlock { (transaction: YapDatabaseReadTransaction,
                                                                collection:String,
                                                                       key:String,
                                                                    object:AnyObject,
                                                                  metadata: AnyObject?) -> String? in
            if(!(object is T.Coder)){
                return nil
            }
            
            let coder = object as! T.Coder
            
            return groupingBlock(collection:collection,
                                        key:key,
                                     object:coder.value)
        }
        
        
        let sorting = YapDatabaseViewSorting.withRowBlock { (transaction: YapDatabaseReadTransaction,
                                                                   group:String,
                                                             collection1: String,
                                                                    key1: String,
                                                                 object1:AnyObject,
                                                               metadata1:AnyObject?,
                                                             collection2:String,
                                                                    key2:String,
                                                                 object2:AnyObject,
                                                               metadata2:AnyObject?) -> NSComparisonResult in
            let coder1 = object1 as! T.Coder
            let coder2 = object2 as! T.Coder
            
            return sortingBlock(  group: group,
                            collection1: collection1,
                                   key1: key1,
                                object1: coder1.value,
                            collection2: collection2,
                                   key2: key2,
                                object2: coder2.value)
            
        }
        
        let view = YapDatabaseView(grouping: grouping, sorting: sorting)
        
        self.database.registerExtension(view, withName: viewName)
        
    }



    public func addView<T where
                        T: CanBePersistedProtocol,
                        T: NSCoding>
        (     viewName: String,
              groupingBlock:((collection: String,
                              key: String,
                              object: T)->String?),

              sortingBlock: ((     group: String,
                                   collection1: String,
                                   key1: String,
                                   object1: T,
                                   collection2: String,
                                   key2: String,
                                   object2: T) -> NSComparisonResult)){


        let grouping = YapDatabaseViewGrouping.withRowBlock { (transaction: YapDatabaseReadTransaction,
                                                               collection:String,
                                                               key:String,
                                                               object:AnyObject,
                                                               metadata: AnyObject?) -> String? in
            if(!(object is T)){
                return nil
            }

            
            return groupingBlock(collection:collection,
                    key:key,
                    object:object as! T)
        }


        let sorting = YapDatabaseViewSorting.withRowBlock { (transaction: YapDatabaseReadTransaction,
                                                             group:String,
                                                             collection1: String,
                                                             key1: String,
                                                             object1:AnyObject,
                                                             metadata1:AnyObject?,
                                                             collection2:String,
                                                             key2:String,
                                                             object2:AnyObject,
                                                             metadata2:AnyObject?) -> NSComparisonResult in
            

            return sortingBlock(  group: group,
                    collection1: collection1,
                    key1: key1,
                    object1: object1 as! T,
                    collection2: collection2,
                    key2: key2,
                    object2: object2 as! T)

        }

        let view = YapDatabaseView(grouping: grouping, sorting: sorting)

        self.database.registerExtension(view, withName: viewName)

    }
    
    
    
    public func getAll< T where
                        T: CanBePersistedProtocol,
                        T: ValueCoding,
                        T.Coder: NSCoding,
                        T.Coder.ValueType == T>(viewName:String)->[T]{
        var resultArray = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            
            let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as! YapDatabaseViewTransaction
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateGroupsUsingBlock({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                    viewTransaction.enumerateKeysAndObjectsInGroup(group, usingBlock: { (collection:String, key: String, object:AnyObject, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        let coder = object as! T.Coder
                        resultArray.append(coder.value)
                    })
                })
            }
        }
        
        return resultArray
 
    }
    
    public func getAll< T where
                        T: CanBePersistedProtocol,
                        T: NSCoding> (viewName:String)->[T]{
        
        var resultArray = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            
            let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as! YapDatabaseViewTransaction
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateGroupsUsingBlock({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                    viewTransaction.enumerateKeysAndObjectsInGroup(group, usingBlock: { (collection:String, key: String, object:AnyObject, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                        resultArray.append(object as! T)
                    })
                })
            }
        }
        
        return resultArray
        
    }
    

    
    
    public func getAll< T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.ValueType == T>(viewName:String,groupName:String)->[T]{
        var resultArray = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateKeysAndObjectsInGroup(groupName, usingBlock: { (collection:String, key: String, object:AnyObject, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                    let coder = object as! T.Coder
                    resultArray.append(coder.value)
                })
            }
            
        }
        
        return resultArray
    }
    
    
    public func getAll< T where
        T: CanBePersistedProtocol,
        T: NSCoding>(viewName:String,groupName:String)->[T]{
        var resultArray = [T]()
        
        self.readConnection.readWithBlock { (transaction:YapDatabaseReadTransaction) in
            
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateKeysAndObjectsInGroup(groupName, usingBlock: { (collection:String, key: String, object:AnyObject, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                    resultArray.append(object as! T)
                })
            }
            
        }
        
        return resultArray
    }


    
    
    
}
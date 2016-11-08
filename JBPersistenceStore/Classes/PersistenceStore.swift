//
//  DataBaseStore.swift
//  Pods
//
//  Created by Jan Bartel on 27.03.16.
//
//

import Foundation
import YapDatabase
import YapDatabase.YapDatabaseView

import ValueCoding
import JBPersistenceStore_Protocols



open class PersistenceStore : PersistenceStoreProtocol{
    
    var database : YapDatabase
    internal let readConnection : YapDatabaseConnection
    internal let writeConnection : YapDatabaseConnection
    
    public init(databaseFilename: String){
        let databasePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(databaseFilename + ".sqlite").absoluteString
        
        self.database = YapDatabase(path: databasePath)
        self.readConnection  = self.database.newConnection()
        self.writeConnection = self.database.newConnection()
    }
    
    
    open func persist<
        T>(_ item: T) -> T where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T {
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            let coder = T.Coder(item)
            transaction.setObject(coder, forKey: item.identifier(), inCollection: T.collectionName())
        }
        
        return item
    }
    
    
    open func persist<
        T>(_ item: T) -> T where
        T: CanBePersistedProtocol,
        T: NSCoding {
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.setObject(item, forKey: item.identifier(), inCollection: T.collectionName())
        }
        
        return item
    }
    
    
    open func persist(_ item: CanBePersistedProtocol & NSCoding) -> CanBePersistedProtocol & NSCoding {
    
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            let collection = type(of: item.self).collectionName()
            transaction.setObject(item, forKey: item.identifier(), inCollection: collection)
        }
        
        return item
        
    }
    
    open func delete<
        T>(_ identifier: String, type: T.Type) where
        T: CanBePersistedProtocol,
        T: NSCoding{
        
        let collection = type.collectionName()
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObject(forKey: identifier, inCollection: collection)
        }
    }
    
    open func delete(_ item: CanBePersistedProtocol) -> CanBePersistedProtocol{
        let collection = type(of: item.self).collectionName()
        let identifier = item.identifier()
        
        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            transaction.removeObject(forKey: identifier, inCollection: collection)
        }
        
        return item
    }
    
    open func get<
        T>(_ identifier: String) -> T? where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T{
        
        var item : T?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            
            let coder = transaction.object(forKey: identifier, inCollection: T.collectionName()) as! T.Coder
            item = coder.value
            
        }
        
        return item
    }
    
    
    open func get<
        T>(_ identifier: String) -> T? where
        T: CanBePersistedProtocol,
        T: NSCoding{
        
        var item : T?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            item = transaction.object(forKey: identifier, inCollection: T.collectionName()) as! T?
        }
        
        return item

    
    }
    
    open func get(_ identifier: String, type: CanBePersistedProtocol.Type) -> CanBePersistedProtocol?
    {
        
        var item : CanBePersistedProtocol?
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! CanBePersistedProtocol?
        }
        
        return item
        
    }

    

    open func exists<T>(_ item : T) -> Bool where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T{
        
        let identifier = item.identifier()
        let collection = T.collectionName()
        
        var exists  = false
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObject(forKey: identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    }
    
    
    
    open func exists<T>(_ item : T) -> Bool where
        T: CanBePersistedProtocol,
        T: NSCoding{
    
        let identifier = item.identifier()
        let collection = T.collectionName()
        
        var exists  = false
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObject(forKey: identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    }
    
    
    open func exists<T>(_ identifier : String,type : T.Type) -> Bool where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T{
        
        let identifier = identifier
        let collection = type.collectionName()
        
        var exists  = false
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObject(forKey: identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    
    }
    
    
    open func exists<T>(_ identifier : String,type : T.Type) -> Bool where
        T: CanBePersistedProtocol,
        T: NSCoding{
        
        let identifier = identifier
        let collection = type.collectionName()
        
        var exists  = false
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            if(transaction.hasObject(forKey: identifier, inCollection: collection)){
                exists = true
            }
        }
        return exists
    }

    
    
    open func getAll<
        T>(_ type: T.Type) -> [T] where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T{
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                let coder = object as! T.Coder
                items.append(coder.value )
            } as! (String, Any, Any?, UnsafeMutablePointer<ObjCBool>) -> Void)
        }
        
        return items
    }
    
    
    open func getAll<
        T>(_ type: T.Type) -> [T] where
        T: CanBePersistedProtocol,
        T: NSCoding{
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                items.append(object as! T)
            })
        }
            
        return items
    }

    
 

    
    
    open func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) -> [T] where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T{
        
        let collection = type.collectionName()
    
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                let coder = object as! T.Coder
                if(includeElement(coder.value)){
                    items.append(coder.value )
                }
            } as! (String, Any, Any?, UnsafeMutablePointer<ObjCBool>) -> Void)
        
        }
        
        return items
    
    }
    
    
    open func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) -> [T] where
        T: CanBePersistedProtocol,
        T: NSCoding{
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: AnyObject, metadata: AnyObject?, stop: UnsafeMutablePointer<ObjCBool>) in
                if(includeElement(object as! T)){
                    items.append(object as! T)
                }
            } as! (String, Any, Any?, UnsafeMutablePointer<ObjCBool>) -> Void)
            
        }
        
        return items
        
    }

    
    
    open func addView<T>
                        (     _ viewName: String,
                              
                              groupingBlock:@escaping ((  _ collection: String,
                                                       _ key: String,
                                                    _ object: T)->String?),
                              
                              sortingBlock: @escaping ((      _ group: String,
                                               _ collection1: String,
                                                      _ key1: String,
                                                   _ object1: T,
                                               _ collection2: String,
                                                      _ key2: String,
                                                   _ object2: T) -> ComparisonResult)) where
                        T: CanBePersistedProtocol,
                        T: ValueCoding,
                        T.Coder: NSCoding,
                        T.Coder.Value == T{
        
        
        let grouping = YapDatabaseViewGrouping.withRowBlock { (transaction: YapDatabaseReadTransaction,
                                                               collection:String,
                                                               key:String,
                                                               object:Any,
                                                               metadata: Any?) -> String? in
            if(!(object is T.Coder)){
                return nil
            }
            
            let coder = object as! T.Coder
            
            return groupingBlock(collection, key, coder.value)
        }
        

        
        let sorting = YapDatabaseViewSorting.withRowBlock { (transaction: YapDatabaseReadTransaction,
                                                                   group:String,
                                                             collection1: String,
                                                                    key1: String,
                                                                 object1:Any,
                                                               metadata1:Any?,
                                                             collection2:String,
                                                                    key2:String,
                                                                 object2:Any,
                                                               metadata2:Any?) -> ComparisonResult in
            
            let coder1 = object1 as! T.Coder
            let coder2 = object2 as! T.Coder
            
            return sortingBlock(  group,
                                  collection1,
                                  key1,
                                  coder1.value,
                                  collection2,
                                  key2,
                                  coder2.value)
            
        }
                            
                            
        let view = YapDatabaseView(grouping: grouping, sorting: sorting)
        
        self.database.register(view, withName: viewName)
        
    }



    open func addView<T>
        (     _ viewName: String,
              groupingBlock:@escaping (( _ collection: String,
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
                        T: NSCoding{


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
    
    
    
    open func getAll< T>(_ viewName:String)->[T] where
                        T: CanBePersistedProtocol,
                        T: ValueCoding,
                        T.Coder: NSCoding,
                        T.Coder.Value == T{
        var resultArray = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                
                viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                    
                    let enumerationBlock : (String, String, Any, Any, UInt, UnsafeMutablePointer<ObjCBool>) -> Swift.Void =
                        { (myCollection: String, myKey: String, myObject: Any, myMetadata:Any, myIndex:UInt, myStop:UnsafeMutablePointer<ObjCBool>) in
                            let coder = myObject as! T.Coder
                            resultArray.append(coder.value)
                    }


                    viewTransaction.enumerateRows(inGroup: group, with:[], using: enumerationBlock)
                    
                    print(group)
                })
            
            }
        }
        
        return resultArray
 
    }
    
    open func getAll< T> (_ viewName:String)->[T] where
                        T: CanBePersistedProtocol,
                        T: NSCoding{
        
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
    

    
    
    open func getAll< T>(_ viewName:String,groupName:String)->[T] where
        T: CanBePersistedProtocol,
        T: ValueCoding,
        T.Coder: NSCoding,
        T.Coder.Value == T{
        var resultArray = [T]()
        
        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in
            
            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                    let coder = object as! T.Coder
                    resultArray.append(coder.value)
                } as! (String, String, Any, UInt, UnsafeMutablePointer<ObjCBool>) -> Void)
            }
            
        }
        
        return resultArray
    }
    
    
    open func getAll< T>(_ viewName:String,groupName:String)->[T] where
        T: CanBePersistedProtocol,
        T: NSCoding{
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


    
    
    
}

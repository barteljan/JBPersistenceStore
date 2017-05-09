//
//  PersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 27.03.16.
//
//
import JBPersistenceStore_Protocols

/*

open class PersistenceStore : AnyPersistenceStore, PersistenceStoreProtocol{

    
    public convenience init(databaseFilename: String){
        self.init(databaseFilename: databaseFilename, version: 0, changeVersionHandler: {(oldVersion: Int,newVerion: Int) -> Void in })
    }
    
    public init(databaseFilename: String, version : Int ,changeVersionHandler: ((Int,Int) -> Void)?){
        
              
        super.init(version: version,changeVersionHandler: changeVersionHandler)
        
    }
    
    public func persist<T>(_ item: T) -> T {
        return item
    }
    
    public func delete<T>(_ item: T) -> T {
        return item
    }

    public override func get<T>(_ identifier: String) -> T? {
        return nil
    }
    
    public override func get<T>(_ identifier: String, type: T.Type) -> T? {
        return nil
    }

    public override func exists<T>(_ item : T) -> Bool {
        return false
    }
    
    public override func exists<T>(_ identifier : String,type : T.Type) -> Bool {
        return false
    }
    
    public override func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) -> [T] {
        return [T]()
    }
    
    public override func addView<T>
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
        _ object2: T) throws -> ComparisonResult)){
    
    
    }
    
    public override func getAll<T>(_ type: T.Type) -> [T] {
        return [T]()
    }
    
    public override func getAll<T>(_ viewName:String)->[T]{
        return [T]()
    }
    
    public override func getAll<T>(_ viewName:String,groupName:String)->[T]{
        return [T]()
    }
    
}

*/



/*
import Foundation
import YapDatabase
import YapDatabase.YapDatabaseView

import ValueCoding
import JBPersistenceStore_Protocols


open class PersistenceStore : PersistenceStoreProtocol{

    var database : YapDatabase
    internal let readConnection : YapDatabaseConnection
    internal let writeConnection : YapDatabaseConnection

    internal var _version : Int
    internal var changeVersionHandler : ((Int,Int) -> Void)!


    public convenience init(databaseFilename: String){
        self.init(databaseFilename: databaseFilename, version: 0, changeVersionHandler: {(oldVersion: Int,newVerion: Int) -> Void in })
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

    open func version() -> Int{
        return self._version
    }


    open func persist<T>(_ item: T) -> T where T: CanBePersistedProtocol,
                                               T: ValueCoding,
                                               T.Coder: NSCoding,
                                               T.Coder.Value == T {

        self.writeConnection.readWrite { (transaction : YapDatabaseReadWriteTransaction) in
            let coder = T.Coder(item)
            transaction.setObject(coder, forKey: item.identifier(), inCollection: T.collectionName())
        }

        return item
    }


    open func persist<T>(_ item: T) -> T where T: CanBePersistedProtocol,
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

    open func delete<T>(_ identifier: String, type: T.Type) where T: CanBePersistedProtocol,
                                                                  T: NSCoding {

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

    open func get<T>(_ identifier: String) -> T? where T: CanBePersistedProtocol,
                                                       T: ValueCoding,
                                                       T.Coder: NSCoding,
                                                       T.Coder.Value == T {
        var item : T?

        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in

            let collectionName = T.collectionName()
            if let coder  = transaction.object(forKey: identifier, inCollection: collectionName) as? T.Coder {
                item = coder.value
            }
        
        }

        return item
    }


    open func get<T>(_ identifier: String) -> T? where T: CanBePersistedProtocol,
                                                       T: NSCoding {

        var item : T?

        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            item = transaction.object(forKey: identifier, inCollection: T.collectionName()) as! T?
        }

        return item

    }

    open func get(_ identifier: String, type: CanBePersistedProtocol.Type) -> CanBePersistedProtocol? {

        var item : CanBePersistedProtocol?

        self.readConnection.read { (transaction: YapDatabaseReadTransaction) in
            let collectionName = type.collectionName()
            item = transaction.object(forKey: identifier, inCollection:collectionName) as! CanBePersistedProtocol?
        }

        return item

    }



    open func exists<T>(_ item : T) -> Bool where T: CanBePersistedProtocol,
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



    open func exists<T>(_ item : T) -> Bool where T: CanBePersistedProtocol,
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


    open func exists<T>(_ identifier : String,type : T.Type) -> Bool where T: CanBePersistedProtocol,
                                                                           T: ValueCoding,
                                                                           T.Coder: NSCoding,
                                                                           T.Coder.Value == T {
                                                                            
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


    open func exists<T>(_ identifier : String,type : T.Type) -> Bool where T: CanBePersistedProtocol,
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



    open func getAll<T>(_ type: T.Type) -> [T] where T: CanBePersistedProtocol,
                                                     T: ValueCoding,
                                                     T.Coder: NSCoding,
                                                     T.Coder.Value == T {

        let collection = type.collectionName()

        var items : [T] = [T]()

        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in

            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop: UnsafeMutablePointer<ObjCBool>) in
                
                if let coder = object as? T.Coder {
                    items.append(coder.value )
                }
                
            })

        }

        return items
    }


    open func getAll<T>(_ type: T.Type) -> [T] where T: CanBePersistedProtocol,
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


    open func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) -> [T] where T: CanBePersistedProtocol,
                                                                                             T: ValueCoding,
                                                                                             T.Coder: NSCoding,
                                                                                             T.Coder.Value == T {

        let collection = type.collectionName()

        var items : [T] = [T]()

        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in

            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop: UnsafeMutablePointer<ObjCBool>) in
                if let coder = object as? T.Coder{
                    if(includeElement(coder.value)){
                        items.append(coder.value )
                    }
                }
            })

        }

        return items

    }


    open func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) -> [T] where T: CanBePersistedProtocol,
                                                                                             T: NSCoding{

        let collection = type.collectionName()

        var items : [T] = [T]()

        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in

            transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if(includeElement(object as! T)){
                    items.append(object as! T)
                }
            })

        }

        return items

    }



    open func addView<T>( _ viewName: String,
                       groupingBlock:@escaping ((  _ collection: String,
                                                          _ key: String,
                                                       _ object: T)->String?),

                        sortingBlock: @escaping ((      _ group: String,
                                                  _ collection1: String,
                                                         _ key1: String,
                                                      _ object1: T,
                                                  _ collection2: String,
                                                         _ key2: String,
                                                      _ object2: T) -> ComparisonResult)) where T: CanBePersistedProtocol,
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

            if let coder = object as? T.Coder {
                return groupingBlock(collection, key, coder.value)
            }

            return nil
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

            if let coder1 = object1 as? T.Coder, let coder2 = object2 as? T.Coder {

                return sortingBlock(  group,
                        collection1,
                        key1,
                        coder1.value,
                        collection2,
                        key2,
                        coder2.value)
            
            }else{
                return ComparisonResult.orderedSame
            }

        }


        let view = YapDatabaseView(grouping: grouping, sorting: sorting)

        self.database.register(view, withName: viewName)

    }


    open func addView<T>( _ viewName: String,
                       groupingBlock:@escaping (( _ collection: String,
                                                         _ key: String,
                                                      _ object: T)->String?),
                        sortingBlock: @escaping ((     _ group: String,
                                                 _ collection1: String,
                                                        _ key1: String,
                                                     _ object1: T,
                                                 _ collection2: String,
                                                        _ key2: String,
                                                     _ object2: T) -> ComparisonResult)) where T: CanBePersistedProtocol,
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



    open func getAll<T>(_ viewName:String)->[T] where T: CanBePersistedProtocol,
                                                      T: ValueCoding,
                                                      T.Coder: NSCoding,
                                                      T.Coder.Value == T {
        var resultArray = [T]()

        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in

            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{

                viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in

                    let enumerationBlock : (String, String, Any, Any, UInt, UnsafeMutablePointer<ObjCBool>) -> Swift.Void =
                    { (myCollection: String, myKey: String, myObject: Any, myMetadata:Any, myIndex:UInt, myStop:UnsafeMutablePointer<ObjCBool>) in
                        if let coder = myObject as? T.Coder {
                            resultArray.append(coder.value)
                        }
                    }
                    
                    viewTransaction.enumerateRows(inGroup: group, with:[], using: enumerationBlock)
                })

            }
        }

        return resultArray

    }

    open func getAll< T> (_ viewName:String)->[T] where T: CanBePersistedProtocol,
                                                        T: NSCoding {

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

    open func getAll< T>(_ viewName:String,groupName:String)->[T] where T: CanBePersistedProtocol,
                                                                        T: ValueCoding,
                                                                        T.Coder: NSCoding,
                                                                        T.Coder.Value == T{
        var resultArray = [T]()

        self.readConnection.read { (transaction:YapDatabaseReadTransaction) in

            if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
                viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with: [], using: { (collection:String,
                                                                                                       key: String,
                                                                                                    object:Any,
                                                                                                     index:UInt,
                                                                                                      stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let coder = object as? T.Coder {
                        resultArray.append(coder.value)
                    }
                })
            }

        }

        return resultArray
    }


    open func getAll< T>(_ viewName:String,groupName:String)->[T] where T: CanBePersistedProtocol,
                                                                        T: NSCoding {
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
*/

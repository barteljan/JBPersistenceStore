//
//  TransactionalNSCodingPersistenceStore.swift
//  CocoaLumberjack
//
//  Created by bartel on 18.12.17.
//

import Foundation
import JBPersistenceStore_Protocols
import YapDatabase
import YapDatabase.YapDatabaseView
import VISPER_Entity

public enum TransactionalNSCodingPersistenceStoreError: Error{
    case NoWriteTransactionFound
    case CannotAddViewInTransaction(viewName: String)
    case CannotOpenAnTransactionInAnOtherTransaction
}

public class TransactionalNSCodingPersistenceStore: TypedPersistenceStoreProtocol{

    public typealias PersistableType = NSCoding & CanBePersistedProtocol
    
    let readTransaction: YapDatabaseReadTransaction?
    let writeTransaction: YapDatabaseReadWriteTransaction?
    
    public init(readTransaction: YapDatabaseReadTransaction){
        self.readTransaction = readTransaction
        self.writeTransaction = nil
    }
    
    public init(writeTransaction: YapDatabaseReadWriteTransaction){
        self.readTransaction = nil
        self.writeTransaction = writeTransaction
    }
    
    func getReadTransaction() -> YapDatabaseReadTransaction{
        if let readTransaction = self.readTransaction {
            return readTransaction
        } else if let writeTransaction = self.writeTransaction {
            return writeTransaction
        }
        fatalError("Need a f... transaction")
    }
    
    public func persist<T>(_ item: T!) throws {
        
        guard let writeTransaction = self.writeTransaction else {
            throw TransactionalNSCodingPersistenceStoreError.NoWriteTransactionFound
        }
        
        guard let myItem = item as? PersistableType else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
        
        writeTransaction.setObject(myItem, forKey: myItem.identifier(), inCollection: type(of: myItem).collectionName())
    }
    
    public func persist<T>(_ item: T!, completion: @escaping () -> ()) throws {
        try self.persist(item)
        completion()
    }
    
    public func delete<T>(_ item: T!) throws {
        
        guard let writeTransaction = self.writeTransaction else {
            throw TransactionalNSCodingPersistenceStoreError.NoWriteTransactionFound
        }
        
        guard let myItem = item as? PersistableType else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
        
        let collection = type(of: myItem).collectionName()
        let identifier = myItem.identifier()
        
        writeTransaction.removeObject(forKey: identifier, inCollection: collection)
    }
    
    public func delete<T>(_ item: T!, completion: @escaping () -> ()) throws {
        try self.delete(item)
        completion()
    }
    
    
    
    public func get<T>(_ identifier: String) throws -> T? {
        
        let transaction = self.getReadTransaction()
        
        guard let type = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        return transaction.object(forKey: identifier, inCollection: type.collectionName()) as! T?
    }
    
    public func get<T>(_ identifier: String, completion: @escaping (T?) -> Void) throws {
        let item: T? = try self.get(identifier)
        completion(item)
    }
    
    
    public func getAll<T>(_ type: T.Type) throws -> [T] {
        
        let transaction = self.getReadTransaction()
        
        guard let type = T.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        let collection = type.collectionName()
        
        var items : [T] = [T]()
        transaction.enumerateRows(inCollection: collection, using: { (key: String, object: Any, metadata: Any?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            items.append(object as! T)
        })
        
        return items
    }
    
    public func getAll<T>(_ type: T.Type, completion: @escaping ([T]) -> Void) throws {
        let items: [T] = try self.getAll(type)
        completion(items)
    }
    
    public func getAll<T>(_ viewName: String) throws -> [T] {
        
        let transaction = self.getReadTransaction()
        
        guard T.self is PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        var resultArray : [T] = [T]()
        
        if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
            viewTransaction.enumerateGroups({ (group:String, stop:UnsafeMutablePointer<ObjCBool>) in
                viewTransaction.enumerateKeysAndObjects(inGroup: group, with: [], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                    resultArray.append(object as! T)
                })
            })
        }
        
        return resultArray
    }
    
    public func getAll<T>(_ viewName: String, completion: @escaping ([T]) -> Void) throws {
        let items : [T] = try self.getAll(viewName)
        completion(items)
    }
    
    public func getAll<T>(_ viewName: String, groupName: String) throws -> [T] {
        
        let transaction = self.getReadTransaction()
        
        guard T.self is PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : T.Type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        var resultArray : [T] = [T]()
        
        if let viewTransaction : YapDatabaseViewTransaction = transaction.ext(viewName) as? YapDatabaseViewTransaction{
            viewTransaction.enumerateKeysAndObjects(inGroup: groupName, with:[], using: { (collection:String, key: String, object:Any, index:UInt, stop:UnsafeMutablePointer<ObjCBool>) in
                
                resultArray.append(object as! T)
            })
        }
        
        return resultArray
    }
    
    public func getAll<T>(_ viewName: String, groupName: String, completion: @escaping ([T]) -> Void) throws {
        let items : [T] = try self.getAll(viewName, groupName: groupName)
        completion(items)
    }
    
    public func exists<T>(_ item: T!) throws -> Bool {
        let transaction = self.getReadTransaction()
        
        if(!self.isResponsible(for: item)){
            return false
        }
    
        guard let myItem = item as? PersistableType else {
            throw PersistenceStoreError.CannotUse(object : item, inStoreWithType: PersistableType.Type.self)
        }
        
        let collection = type(of: myItem.self).collectionName()
        let identifier = myItem.identifier()
        
        return transaction.hasObject(forKey: identifier, inCollection: collection)
    }
    
    public func exists<T>(_ item: T!, completion: @escaping (Bool) -> Void) throws {
        let exists = try self.exists(item)
        completion(exists)
    }
    
    public func exists<T>(_ identifier: String, type: T.Type) throws -> Bool {
        let transaction = self.getReadTransaction()
        
        print(type)
        
        if(!self.isResponsible(forType: type)){
            return false
        }
        
        guard let myType = type.self as? PersistableType.Type else {
            throw PersistenceStoreError.CannotUseType(type : type.self, inStoreWithType: PersistableType.Type.self)
        }
        
        let collection = myType.collectionName()
    
        return transaction.hasObject(forKey: identifier, inCollection: collection)
    }
    
    public func exists<T>(_ identifier: String, type: T.Type, completion: @escaping (Bool) -> Void) throws {
        let exists = try self.exists(identifier, type: type)
        completion(exists)
    }
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) throws -> [T] {
        let list = try self.getAll(T.self)
        return list.filter(includeElement)
    }
    
    public func filter<T>(_ type: T.Type, includeElement: @escaping (T) -> Bool, completion: @escaping ([T]) -> Void) throws {
        try self.getAll(T.self) { (items : [T]) in
            let filtered = items.filter(includeElement)
            completion(filtered)
        }
    }
    
    public func addView<T>(_ viewName: String, groupingBlock: @escaping ((String, String, T) -> String?), sortingBlock: @escaping ((String, String, String, T, String, String, T) -> ComparisonResult)) throws {
        throw TransactionalNSCodingPersistenceStoreError.CannotAddViewInTransaction(viewName: viewName)
    }
    
    public func transaction(transaction: @escaping (EntityStore) throws -> Void) throws {
        fatalError("cannot open transaction in an other transaction")
    }
    
}

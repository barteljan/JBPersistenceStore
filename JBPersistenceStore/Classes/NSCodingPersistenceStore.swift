//
//  NSCodingPersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 08.05.17.
//
//

import Foundation
import JBPersistenceStore_Protocols

public class NSCodingPersistenceStore : TypedPersistenceStoreProtocol{
    
    public typealias PersistableType = NSCoding & CanBePersistedProtocol
    
    let databaseFilename : String
    let _version : Int
    
    public init(databaseFilename: String, version: Int){
        self.databaseFilename = databaseFilename
        self._version = version
    }
    
    public func version() -> Int{
        return self._version
    }
    
    public func persist(_ item: NSCoding & CanBePersistedProtocol) throws {
    
    }
    
    public func persist(_ item: NSCoding & CanBePersistedProtocol,completion: @escaping () -> ()) throws {
    
    }
    
    public func delete(_ item: NSCoding & CanBePersistedProtocol) throws {
    
    }
    
    public func delete(_ item: NSCoding & CanBePersistedProtocol, completion: @escaping () -> ()) throws {
    
    }
    
    public func get<T>(_ identifier: String) throws -> T? {
        return nil
    }
    
    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws {
        
    }
    
    public func get<T>(_ identifier: String, type: T.Type) throws -> T? {
        return nil
    }
    
    public func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws {
        
    }
    
    public func getAll<T>(_ type: (NSCoding & CanBePersistedProtocol).Protocol) throws -> [T] {
        return [T]()
    }
    
    public func getAll<T>(_ type: (NSCoding & CanBePersistedProtocol).Protocol, completion: @escaping (_ items: [T]) -> Void) throws {
        
    }
    
    public func getAll<T>(_ viewName:String) throws ->[T] {
        return [T]()
    }
    
    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws {
    
    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws ->[T] {
        return [T]()
    }
    
    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        
    }
    
    public func exists(_ item: (NSCoding & CanBePersistedProtocol).Protocol, completion: @escaping (Bool) -> Void) throws {
        
    }
    
    
    public func exists(_ item: (NSCoding & CanBePersistedProtocol).Protocol) throws -> Bool {
        return false
    }
    
    
    public func exists(_ identifier : String,type : (NSCoding & CanBePersistedProtocol).Protocol) throws -> Bool {
        return false
    }
    
    public func exists(_ identifier : String,type : (NSCoding & CanBePersistedProtocol).Protocol,  completion: @escaping (_ exists: Bool) -> Void) throws {
    
    }
    
    public func filter<T>(_ type: (NSCoding & CanBePersistedProtocol).Protocol, includeElement: @escaping (T) -> Bool) throws -> [T] {
        return [T]()
    }
    
    public func filter<T>(_ type: (NSCoding & CanBePersistedProtocol).Protocol, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws {
    
    }
    
    public func addView<T>(_ viewName: String,
                 groupingBlock: @escaping ((_ collection: String,
        _ key: String,
        _ object: T)->String?),
                 
                 sortingBlock: @escaping ((     _ group: String,
        _ collection1: String,
        _ key1: String,
        _ object1: T,
        _ collection2: String,
        _ key2: String,
        _ object2: T) throws -> ComparisonResult)) throws {
    
    }
    
}

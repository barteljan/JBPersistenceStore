//
//  AnyPersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 07.05.17.
//
//
/*

import Foundation
import JBPersistenceStore_Protocols

public enum AnyPersistenceStoreError : Error{
    case NoStoreForValue(value: Any)
    case NoStoreForType(type: Any.Type)
}

open class AnyPersistenceStore : AnyPersistenceStoreProtocol{
    
    internal let _version : Int
    internal var changeVersionHandler : ((Int,Int) -> Void)!
    internal var typedStoreFactories = [TypedPersistenceStoreFactoryProtocol]()
    
    public init(version : Int, changeVersionHandler: ((Int,Int) -> Void)?){
        
        if let versionHandler = changeVersionHandler{
            self.changeVersionHandler = versionHandler
        }else{
            self.changeVersionHandler = {(oldVersion: Int,newVerion: Int) -> Void in }
        }
        
        self._version = version
    }
    
    public func version() -> Int {
        return self._version
    }
    
    public func isResponsible(for object: Any) -> Bool {
        do {
            try self.factoryFor(item: object)
            return true
        } catch {
            return false
        }
    }
    
    public func isResponsible(forType type: Any.Type) -> Bool {
        do {
            try self.factoryFor(type: type)
            return true
        } catch {
            return false
        }
    }
    
    public func count() -> Int {
        return self.typedStoreFactories.count
    }
    
    func factoryFor(item: Any) throws -> TypedPersistenceStoreFactoryProtocol{
        
        for factory in self.typedStoreFactories{
            if(factory.isResponsible(for:item)){
                return factory
            }
        }
        
        throw AnyPersistenceStoreError.NoStoreForValue(value: item)
    }
    
    func factoryFor(type: Any.Type) throws -> TypedPersistenceStoreFactoryProtocol{
        
        for factory in self.typedStoreFactories{
            if(factory.isResponsible(forType:type)){
                return factory
            }
        }
        
        throw AnyPersistenceStoreError.NoStoreForType(type: type)
    }
    
    /*
    public func add<T : TypedPersistenceStoreFactoryProtocol>(typedStore: T) {
        let anyStore = AnyTypedPersistenceStore(typedStore)
        let proxy = TypedPersistenceStoreProxy(store: anyStore)
        self.typedPersistenceProxies.append(proxy)
    }
    */
    
    public func add(factory: TypedPersistenceStoreFactoryProtocol){
        self.typedStoreFactories.append(factory)
    }
    
    public func persist(_ item: Any) throws {
        
    }
    
    public func persist(_ item: Any,completion: @escaping () -> ()) throws {
    
    }
    
    public func delete(_ item: Any) throws {
        
    }

    public func delete(_ item: Any, completion: @escaping () -> ()) throws {
        
    }
    
    public func get<T>(_ identifier: String) throws -> T? {
        return nil
    }

    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws  {
        completion(nil)
    }

    public func get<T>(_ identifier: String, type: T.Type) throws -> T?  {
        return nil
    }

    public func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws {
        completion(nil)
    }
    
    public func getAll<T>(_ type: T.Type) throws -> [T] {
        return [T]()
    }

    public func getAll<T>(_ type: T.Type, completion: @escaping (_ items: [T]) -> Void) throws  {
        completion( [T]() )
    }

    public func getAll<T>(_ viewName:String) throws -> [T]  {
        return [T]()
    }

    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws  {
        completion( [T]() )
    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws -> [T] {
        return [T]()
    }

    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        completion( [T]() )
    }
    
    public func exists<T>(_ item : T) throws -> Bool {
        return false
    }

    public func exists<T>(_ item : T, completion: @escaping (_ exists: Bool) -> Void) throws {
        completion(false)
    }

    public func exists<T>(_ identifier : String,type : T.Type) throws -> Bool {
        return false
    }

    public func exists<T>(_ identifier : String,type : T.Type,  completion: @escaping (_ exists: Bool) -> Void) throws {
        completion(false)
    }
    
    public func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) throws -> [T] {
        return [T]()
    }

    public func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws  {
        completion( [T]() )
    }

    public func addView<T>( _ viewName: String,
                         groupingBlock: @escaping ((_ collection: String,
                                                           _ key: String,
                                                        _ object: T)->String?),
              
                         sortingBlock: @escaping ((     _ group: String,
                                                  _ collection1: String,
                                                         _ key1: String,
                                                      _ object1: T,
                                                  _ collection2: String,
                                                         _ key2: String,
                                                      _ object2: T) throws -> ComparisonResult)) throws{
        
    }




}
 */

//
//  AnyTypedPersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 07.05.17.
//
//

import Foundation
import JBPersistenceStore_Protocols

//
//  AnyTypedPersistenceStore.swift
//  Pods
//
//  Created by Jan Bartel on 09.05.17.
//
//

import Foundation



public enum AnyTypedPersistenceStoreError : Error{
    case CannotUse(object : Any, inStoreWithType: Any.Type)
    case CannotRetrieveValue(type: Any.Type,fromStoreWithType: Any.Type, valueWas: Any )
    case CannotRetrieve(type: Any.Type,fromStoreWithType: Any.Type)
    case CannotCheckForExistence(ofItem: Any, inStoreWithType: Any.Type)
    case CannotCheckForExistenceOfIdentifier(identifier: String, withType: Any.Type, inStoreWithType: Any.Type)
    case CannotCreateViewForValues(ofType: Any.Type, inStoreWithType: Any.Type)
}


fileprivate class _AnyTypedPersistenceStoreBase<PersistedType> : TypedPersistenceStoreProtocol{
    
    typealias PersistableType = PersistedType
    
    init() {
        guard type(of: self) != _AnyTypedPersistenceStoreBase.self else {
            fatalError("_AnyTypedPersistenceStoreBase<PersistedType> instances can not be created; create a subclass instance instead")
        }
    }
    
    func version() -> Int {
        fatalError("override me")
    }
    
    func persist(_ item: PersistableType) throws {
        fatalError("override me")
    }
    
    func persist(_ item: PersistableType,completion: @escaping () -> ()) throws {
        fatalError("override me")
    }
    
    
    func delete(_ item: PersistableType) throws {
        fatalError("override me")
    }
    
    func delete(_ item: PersistableType, completion: @escaping () -> ()) throws {
        fatalError("override me")
    }
    
    func get<T>(_ identifier: String) throws -> T? {
        fatalError("override me")
    }
    
    func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws  {
        fatalError("override me")
    }
    
    func get<T>(_ identifier: String, type: T.Type) throws -> T? {
        fatalError("override me")
    }
    
    func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws {
        fatalError("override me")
    }
    
    func getAll<T>(_ type: PersistableType.Type) throws -> [T]  {
        fatalError("override me")
    }
    
    func getAll<T>(_ type: PersistableType.Type, completion: @escaping (_ items: [T]) -> Void) throws {
        fatalError("override me")
    }
    
    func getAll<T>(_ viewName:String) throws ->[T]{
        fatalError("override me")
    }
    
    func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        fatalError("override me")
    }
    
    func getAll<T>(_ viewName:String,groupName:String) throws ->[T] {
        fatalError("override me")
    }
    
    func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        fatalError("override me")
    }
    
    func exists(_ item : PersistableType.Type) throws -> Bool {
        fatalError("override me")
    }
    
    func exists(_ item : PersistableType.Type, completion: @escaping (_ exists: Bool) -> Void) throws{
        fatalError("override me")
    }
    
    func exists(_ identifier : String,type : PersistableType.Type) throws -> Bool {
        fatalError("override me")
    }
    
    func exists(_ identifier : String,type : PersistableType.Type,  completion: @escaping (_ exists: Bool) -> Void) throws{
        fatalError("override me")
    }
    
    func filter<T>(_ type: PersistableType.Type, includeElement: @escaping (T) -> Bool) throws -> [T] {
        fatalError("override me")
    }
    
    
    func filter<T>(_ type: PersistableType.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws {
        fatalError("override me")
    }
    
    func addView<T>(_ viewName: String,
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
        fatalError("override me")
    }
    
}

fileprivate final class _AnyTypedPersistenceStoreBox<Base: TypedPersistenceStoreProtocol>: _AnyTypedPersistenceStoreBase<Base.PersistableType> {
    
    var base: Base
    
    init(_ base: Base) { self.base = base }
    
    func isResponsible(for object: Any) -> Bool{
        return self.base.isResponsible(for: object)
    }
    
    func isResponsible(forType type: Any.Type) -> Bool{
        return self.base.isResponsible(forType: type)
    }
    
    override func version() -> Int {
        return self.base.version()
    }
    
    override func persist(_ item: PersistableType) throws {
        try self.base.persist(item)
    }
    
    override func persist(_ item: PersistableType,completion: @escaping () -> ()) throws {
        try self.base.persist(item, completion: completion)
    }
    
    
    override func delete(_ item: PersistableType) throws {
        try self.base.delete(item)
    }
    
    override func delete(_ item: PersistableType, completion: @escaping () -> ()) throws {
        try self.base.delete(item, completion: completion)
    }
    
    override func get<T>(_ identifier: String) throws -> T? {
        return try self.base.get(identifier)
    }
    
    override func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws  {
        try self.base.get(identifier,completion: completion)
    }
    
    override func get<T>(_ identifier: String, type: T.Type) throws -> T? {
        return try self.base.get(identifier, type: type)
    }
    
    override func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws {
        try self.base.get(identifier, type: type, completion: completion)
    }
    
    override func getAll<T>(_ type: PersistableType.Type) throws -> [T]  {
        return try self.base.getAll(type)
    }
    
    override func getAll<T>(_ type: PersistableType.Type, completion: @escaping (_ items: [T]) -> Void) throws {
        try self.base.getAll(type, completion: completion)
    }
    
    override func getAll<T>(_ viewName:String) throws ->[T]{
        return try self.base.getAll(viewName)
    }
    
    override func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        try self.base.getAll(viewName, completion: completion)
    }
    
    override func getAll<T>(_ viewName:String,groupName:String) throws ->[T] {
        return try self.getAll(viewName,groupName:groupName)
    }
    
    override func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        try getAll(viewName, groupName: groupName, completion: completion)
    }
    
    override func exists(_ item : PersistableType.Type) throws -> Bool {
        return try self.base.exists(item)
    }
    
    override func exists(_ item : PersistableType.Type, completion: @escaping (_ exists: Bool) -> Void) throws {
        return try self.base.exists(item, completion: completion)
    }
    
    override func exists(_ identifier : String,type : PersistableType.Type) throws -> Bool {
        return try self.base.exists(identifier,type: type)
    }
    
    override func exists(_ identifier : String,type : PersistableType.Type,  completion: @escaping (_ exists: Bool) -> Void) throws{
        try self.base.exists(identifier, type: type, completion: completion)
    }
    
    override func filter<T>(_ type: PersistableType.Type, includeElement: @escaping (T) -> Bool) throws -> [T] {
        return try self.base.filter(type, includeElement: includeElement)
    }
    
    
    override func filter<T>(_ type: PersistableType.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws {
        try self.base.filter(type, includeElement: includeElement, completion: completion)
    }
    
    override func addView<T>(_ viewName: String,
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
        try self.base.addView(viewName, groupingBlock: groupingBlock, sortingBlock: sortingBlock)
    }
    
}



public class AnyTypedPersistenceStore<PersistedType> : TypedPersistenceStoreProtocol{
    
    private let box: _AnyTypedPersistenceStoreBase<PersistedType>
    
    public init<Base: TypedPersistenceStoreProtocol>(_ base: Base) where Base.PersistableType == PersistedType {
        box = _AnyTypedPersistenceStoreBox(base)
    }
    
    public func isResponsible(for object: Any) -> Bool{
        return self.box.isResponsible(for: object)
    }
    
    public func isResponsible(forType type: Any.Type) -> Bool{
        return self.box.isResponsible(forType: type)
    }
    
    public func version() -> Int {
        return self.box.version()
    }
    
    public func persist(_ item: PersistedType) throws {
        try self.box.persist(item)
    }
    
    public func persist(_ item: PersistedType,completion: @escaping () -> ()) throws {
        try self.box.persist(item, completion: completion)
    }
    
    
    public func delete(_ item: PersistedType) throws {
        try self.box.delete(item)
    }
    
    public func delete(_ item: PersistedType, completion: @escaping () -> ()) throws {
        try self.box.delete(item, completion: completion)
    }
    
    public func get<T>(_ identifier: String) throws -> T? {
        return try self.box.get(identifier)
    }
    
    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws  {
        try self.box.get(identifier,completion: completion)
    }
    
    public func get<T>(_ identifier: String, type: T.Type) throws -> T? {
        return try self.box.get(identifier, type: type)
    }
    
    public func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws {
        try self.box.get(identifier, type: type, completion: completion)
    }
    
    public func getAll<T>(_ type: PersistedType.Type) throws -> [T]  {
        return try self.box.getAll(type)
    }
    
    public func getAll<T>(_ type: PersistedType.Type, completion: @escaping (_ items: [T]) -> Void) throws {
        try self.box.getAll(type, completion: completion)
    }
    
    public func getAll<T>(_ viewName:String) throws ->[T]{
        return try self.box.getAll(viewName)
    }
    
    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        try self.box.getAll(viewName, completion: completion)
    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws ->[T] {
        return try self.getAll(viewName,groupName:groupName)
    }
    
    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        try getAll(viewName, groupName: groupName, completion: completion)
    }
    
    public func exists(_ item : PersistedType.Type) throws -> Bool {
        return try self.box.exists(item)
    }
    
    public func exists(_ item : PersistedType.Type, completion: @escaping (_ exists: Bool) -> Void) throws {
        return try self.box.exists(item, completion: completion)
    }
    
    public func exists(_ identifier : String,type : PersistedType.Type) throws -> Bool {
        return try self.box.exists(identifier,type: type)
    }
    
    public func exists(_ identifier : String,type : PersistedType.Type,  completion: @escaping (_ exists: Bool) -> Void) throws{
        try self.box.exists(identifier, type: type, completion: completion)
    }
    
    public func filter<T>(_ type: PersistedType.Type, includeElement: @escaping (T) -> Bool) throws -> [T] {
        return try self.box.filter(type, includeElement: includeElement)
    }
    
    
    public func filter<T>(_ type: PersistedType.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws {
        try self.box.filter(type, includeElement: includeElement, completion: completion)
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
        try self.box.addView(viewName, groupingBlock: groupingBlock, sortingBlock: sortingBlock)
    }
    
}


/*
public class AnyTypedPersistenceStore <S : TypedPersistenceStoreProtocol> : AnyPersistenceStoreProtocol {
    
    let store : S
    
    public init(store : S){
        self.store = store
    }
    
    public func version() -> Int {
        return self.store.version()
    }
    
    public func isResponsible(for object: Any) -> Bool {
        return self.store.isResponsible(for: object)
    }
    
    public func isResponsible(forType type:Any.Type) -> Bool {
        return self.store.isResponsible(forType: type)
    }
    
    public func persist(_ item: Any) throws {
        
        if(self.store.isResponsible(for:item)){
            if let item = item as? S.PersistableType {
                try self.store.persist(item)
            }else {
                throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
        }
        
        
        
    }
    
    public func persist(_ item: Any,completion: @escaping () -> ()) throws {
        
        if(self.store.isResponsible(for:item)){
            if let item = item as? S.PersistableType {
                try self.store.persist(item, completion: completion)
            }else {
                throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
        }
    }
    
    public func delete(_ item: Any) throws {
        if(self.store.isResponsible(for:item)){
            
            if let item = item as? S.PersistableType {
                try self.store.delete(item)
            }else {
                throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
            }
            
        }else {
            throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
        }
    }
    
    public func delete(_ item: Any, completion: @escaping () -> ()) throws {
        if(self.store.isResponsible(for:item)){
            if let item = item as? S.PersistableType {
                try self.store.delete(item, completion: completion)
            }else {
                throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotUse(object: item, inStoreWithType: S.PersistableType.self)
        }
    }
    
    public func get<T>(_ identifier: String) throws -> T? {
        
        if(self.store.isResponsible(forType: T.Type.self)){
        
            let storeContent : T? = try self.store.get(identifier)
            
                if let value = storeContent as? T?{
                    return value
                }else{
                    throw AnyTypedPersistenceStoreError.CannotRetrieveValue(type: T.Type.self, fromStoreWithType: S.PersistableType.self, valueWas: storeContent)
                }
            
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
    }
    
    public func get<T>(_ identifier: String, completion: @escaping (_ item: T?) -> Void ) throws  {
        
        if(self.store.isResponsible(forType: T.Type.self)){
            if T.Type.self is S.PersistableType {
                try self.store.get(identifier) { (_ item: S.PersistableType?) in
                    completion(item as! T)
                }
            }else {
                throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
            }
        }else {
                throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
        
    }
    
    public func get<T>(_ identifier: String, type: T.Type) throws -> T?  {
        
        if(self.store.isResponsible(forType: T.Type.self)){
            if T.Type.self is S.PersistableType {
                
                let storeContent = try self.store.get(identifier, type: type as! S.PersistableType.Type)
                
                if let value = storeContent as? T?{
                    return value
                }else{
                    throw AnyTypedPersistenceStoreError.CannotRetrieveValue(type: T.Type.self, fromStoreWithType: S.PersistableType.self, valueWas: storeContent)
                }
                
            }else {
                throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
    }
    
    public func get<T>(_ identifier: String, type: T.Type, completion: @escaping (_ item: T?) -> Void ) throws {
        
        if(self.store.isResponsible(forType: T.Type.self)){
            try self.store.get(identifier, type: type, completion: completion)
        }else{
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
        
    }
    
    public func getAll<T>(_ type: T.Type) throws -> [T] {
        
        if(self.store.isResponsible(forType: type)){
            
            if let myType = type as? S.PersistableType.Type{
                return try self.store.getAll(myType)
            }else {
                throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
            }
            
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
        
    }
    
    public func getAll<T>(_ type: T.Type, completion: @escaping (_ items: [T]) -> Void) throws  {
        
        if(self.store.isResponsible(forType: type)){
            if let myType = type as? S.PersistableType.Type {
                try self.store.getAll(myType, completion: completion)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
        
    }
    
    public func getAll<T>(_ viewName:String) throws -> [T]  {
        
        if(self.store.isResponsible(forType: T.Type.self)){
            return try self.store.getAll(viewName)
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
    
    }
    
    public func getAll<T>(_ viewName:String, completion: @escaping (_ items: [T]) -> Void) throws  {
        
        if(self.store.isResponsible(forType: T.Type.self)){
            try self.store.getAll(viewName, completion: completion)
        } else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }

    }
    
    public func getAll<T>(_ viewName:String,groupName:String) throws -> [T] {
        if(self.store.isResponsible(forType: T.Type.self)){
            return try self.store.getAll(viewName, groupName: groupName)
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
    }
    
    public func getAll<T>(_ viewName:String,groupName:String, completion: @escaping (_ items: [T]) -> Void) throws {
        if(self.store.isResponsible(forType: T.Type.self)){
            try self.store.getAll(viewName, groupName: groupName, completion: completion)
        } else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }

    }
    
    public func exists<T>(_ item : T) throws -> Bool {
        if(self.store.isResponsible(forType: T.Type.self)){
            
            if let myItem = item as? S.PersistableType.Type{
                return try self.store.exists(myItem)
            }else {
                throw AnyTypedPersistenceStoreError.CannotCheckForExistence(ofItem: item, inStoreWithType: S.PersistableType.self)
            }
            
        }else {
             throw AnyTypedPersistenceStoreError.CannotCheckForExistence(ofItem: item, inStoreWithType: S.PersistableType.self)
        }
    }
    
    public func exists<T>(_ item : T, completion: @escaping (_ exists: Bool) -> Void) throws {
        if(self.store.isResponsible(forType: T.Type.self)){
            if let myItem = item as? S.PersistableType.Type{
                try self.store.exists(myItem,completion: completion)
            }else {
                throw AnyTypedPersistenceStoreError.CannotCheckForExistence(ofItem: item, inStoreWithType: S.PersistableType.self)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotCheckForExistence(ofItem: item, inStoreWithType: S.PersistableType.self)
        }
    }
    
    public func exists<T>(_ identifier : String,type : T.Type) throws -> Bool {
        
        if(self.store.isResponsible(forType: type)){
            
            if let myType = type as? S.PersistableType.Type {
                return try self.store.exists(identifier, type: myType)
            }else {
                 throw AnyTypedPersistenceStoreError.CannotCheckForExistenceOfIdentifier(identifier: identifier, withType: type, inStoreWithType: S.PersistableType.self)
            }
            
        }else {
            throw AnyTypedPersistenceStoreError.CannotCheckForExistenceOfIdentifier(identifier: identifier, withType: type, inStoreWithType: S.PersistableType.self)
        }
        
    }
    
    public func exists<T>(_ identifier : String,type : T.Type,  completion: @escaping (_ exists: Bool) -> Void) throws {
        
        if(self.store.isResponsible(forType: type)){
            if let myType = type as? S.PersistableType.Type {
                try self.store.exists(identifier, type: myType, completion: completion)
            }else {
                throw AnyTypedPersistenceStoreError.CannotCheckForExistenceOfIdentifier(identifier: identifier, withType: type, inStoreWithType: S.PersistableType.self)
            }
        }else {
            throw AnyTypedPersistenceStoreError.CannotCheckForExistenceOfIdentifier(identifier: identifier, withType: type, inStoreWithType: S.PersistableType.self)
        }
    }
    
    public func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool) throws -> [T] {
        if(self.store.isResponsible(forType: type)){
            
            if let myType = type as? S.PersistableType.Type{
                return try self.store.filter(myType, includeElement: includeElement)
            }else {
                throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
            }
            
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }

    }
    
    public func filter <T>(_ type: T.Type, includeElement: @escaping (T) -> Bool, completion: @escaping (_ items: [T]) -> Void) throws  {
        
        
        if(self.store.isResponsible(forType: type)){
            
            if let myType = type as? S.PersistableType.Type{
                try self.store.filter(myType, includeElement: includeElement, completion: completion)
            }else {
                throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
            }
            
        }else {
            throw AnyTypedPersistenceStoreError.CannotRetrieve(type: T.Type.self, fromStoreWithType: S.PersistableType.self)
        }
        
        
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
        _ object2: T) throws -> ComparisonResult)) throws {
        
        if(self.store.isResponsible(forType: T.Type.self)){
            try self.store.addView(viewName,
                               groupingBlock: groupingBlock,
                               sortingBlock: sortingBlock)
        }else {
            throw AnyTypedPersistenceStoreError.CannotCreateViewForValues(ofType: T.Type.self, inStoreWithType: S.PersistableType.self)
        }
        
    }
    
    

    

}
 */

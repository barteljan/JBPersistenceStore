//
//  DemoModel.swift
//  JBPersistenceStore_Example

import Foundation
import JBPersistenceStore_Protocols

// Here is a "minimal implementation" of a persistable Model that can be stored to an NSCodingPersistenceStore
public class DemoModel: NSObject, NSCoding {
    private enum Keys: String {
        case id, name, collectionName
    }

    var modelId: String
    var modelName: String

    // This is an initalizer the developer would use to create (initial?) Models.
    public init(modelId: String, modelName: String) {
        self.modelId = modelId
        self.modelName = modelName
    }

    // An initializer that the store will use to resurrect your model
    public required init?(coder aDecoder: NSCoder) {
        if let id = aDecoder.decodeObject(forKey: Keys.id.rawValue) as? String, let modelName = aDecoder.decodeObject(forKey: Keys.name.rawValue) as? String {
            self.modelId = id
            self.modelName = modelName
        } else {
            fatalError("could not decode object \(#file)")
        }
    }

    // The method that the store will use to persist your model
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.modelId, forKey: Keys.id.rawValue)
        aCoder.encode(self.modelName, forKey: Keys.name.rawValue)
    }
}

extension DemoModel: CanBePersistedProtocol {
    // an identifier for a group. Must be unique amongst a Type.
    public static func collectionName() -> String {
        return Keys.collectionName.rawValue
    }

    // an identifier for a single model. Must be unique. It is common to use UUIDs here.
    public func identifier() -> String {
        return self.modelId
    }
}

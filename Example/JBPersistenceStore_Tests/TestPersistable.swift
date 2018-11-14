//
//  TestPersistable.swift
//  JBPersistenceStore
//
//  Created by Jan Bartel on 08.05.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import JBPersistenceStore
import JBPersistenceStore_Protocols

class TestPersistable: NSObject, NSCoding, CanBePersistedProtocol {
    @objc let id: String
    @objc let title: String

    @objc public init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let title = aDecoder.decodeObject(forKey: "title") as! String
        self.init(id: id, title: title)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.title, forKey: "title")
    }

    @objc public static func collectionName() -> String {
        return "TestPersistable"
    }

    @objc public func identifier() -> String {
        return self.id
    }
}

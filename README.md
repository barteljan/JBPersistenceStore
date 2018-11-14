# JBPersistenceStore

[![CI Status](http://img.shields.io/travis/Jan Bartel/JBPersistenceStore.svg?style=flat)](https://travis-ci.org/Jan Bartel/JBPersistenceStore)
[![Version](https://img.shields.io/cocoapods/v/JBPersistenceStore.svg?style=flat)](http://cocoapods.org/pods/JBPersistenceStore)
[![License](https://img.shields.io/cocoapods/l/JBPersistenceStore.svg?style=flat)](http://cocoapods.org/pods/JBPersistenceStore)
[![Platform](https://img.shields.io/cocoapods/p/JBPersistenceStore.svg?style=flat)](http://cocoapods.org/pods/JBPersistenceStore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JBPersistenceStore is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JBPersistenceStore"
```

## Usage

### Models

The Models you want to persist must implement NSCoding and CanBePersistedProtocol. They must also inherit from NSObjet.  
Hint: You can implement CanBePersistedProtocol inside an Extension to make your file more tidy.

```swift
public class DemoModel: NSObject, NSCoding {
    (...)
}

extension DemoModel: CanBePersistedProtocol {
    (...)
}
```

### Implementing CanBePersistedProtocol

To implement CanBePersistedProtocol you can (but don't need to) use a  private Key enum. If so, declare it inside your class:

```swift
public class DemoModel: NSObject, NSCoding {
    private enum Keys: String {
        case id, name, collectionName // one case for any property that shall be persisted plus one for the collectionName
    }

    var modelId: String
    var modelName: String

    (...)
}
```

each property you want to persist needs a key. Keep in mind that one property must be unique (primary key). You can use this property to implement identifier(). In most cases it will be an UUID.  
You can add one case in the enum for your collectionName() as well.  
You must implement collectionName() and identifier(). They return strings for identifying. collectionName() identifies the type in general, identifier() identifies a single model.  

```swift
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
```

### Implementing NSCoding

```swift
public class DemoModel: NSObject, NSCoding {
    (...)

    var modelId: String
    var modelName: String

    (...)

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
```

implementing NSCoding is straight-forward. But keep in mind, that optionals cannot be persisted and that you need casting in some cases.  
This means that you should check for nil while you are decoding, otherwise your app might crash.
Strings can be decoded as Objects and need to be casted to String.
If your class has members to persist that are not primitive types, see here: https://stackoverflow.com/questions/43060636/how-do-i-save-persist-class-objects-that-include-other-classes-with-swift
⚠️ If there are optionals that are nil, just don't persist them but ignore them!

### Creating a store

```swift
let store = NSCodingPersistenceStore(databaseFilename: "db" + UUID().uuidString, version: 0)
```

the UUID should stay the same unless you want to migrate or renew your database.  
Documentation on database updates/migrations will follow.  

### persisting and fetching single items

a model persisted like this:

```swift
let demoModelToPersist = DemoModel(modelId: "38AFCFBE-9EC9-45A3-AAC8-B0164E5ACD5A", modelName: "the single model")
try! store.persist(demoModelToPersist)
```

can be easily fetched like this:

```swift
let deSerializedModel = try! store.get("38AFCFBE-9EC9-45A3-AAC8-B0164E5ACD5A", type: DemoModel.self)
```

### persisting and fetching multiple items

multiple models persisted like this:

```swift

var multipleItems = [
                DemoModel(modelId: "38AFCFBE-9EC9-45A3-AAC8-B0164E5ACD5A", modelName: "first model"),
                DemoModel(modelId: "C3263826-347E-4CAC-B142-0392A11BBE44", modelName: "second model"),
                DemoModel(modelId: "D7CC435A-6975-4089-99E8-80A53B3877C3", modelName: "third model")
                ]

try! store.persist(multipleItems)
```

cannot be easily fetched. But there is a method to fetch all Items of a certain type.

```swift
var multipleItems = [DemoModel]()
try! multipleItems = store.getAll(DemoModel.self)

let yourChoice = multipleItems.filter { /* your magic here */ }
```

### using views for fetching items

follows soon

### check for existence

You can check if a item has been persisted yet like this

```swift
let id = UUID().uuidString
let itemFromSomewhere = DemoModel(modelId: id, modelName: "assume, this item is from an api ore somewhere else")

let itemExits = try! store.exists(itemFromSomewhere)

if itemExits {
    // your reaction
} else {
    // your reaction
}
```

You can check existence via identifier as well

```swift
let itemExists = try! store.exists("45F21990-7C4E-4506-882C-F6C5DBFB5C5B", type: DemoModel.self)
```

Or in case you need completion handler with a completion handler

```swift
try! store.exists("45F21990-7C4E-4506-882C-F6C5DBFB5C5B", type: DemoModel.self, completion: { (exists: Bool) in
    if exists {
        // your reaction here
    } else {
        // your reaction here
    }
})
```

### deleting items

Items can be deleted like this

```swift
let itemToDelete = try! store.get("4FA9578E-D33F-4DBA-98E4-BEA340EEC992", type: DemoModel.self)
try! store.delete(itemToDelete)
```

If you need to take action after deleting items, you can use a completion handler. Useful if you want to update your UI accordingly  

```swift
let itemToDelete = try! store.get("BD5B131F-54A1-4072-85BE-5176945A168E", type: DemoModel.self)
try! store.delete(itemToDelete, completion: {
    updateUI() // your reaction here
})
```


## Author

Jan Bartel, jan.bartel@atino.net

## License

JBPersistenceStore is available under the MIT license. See the LICENSE file for more info.

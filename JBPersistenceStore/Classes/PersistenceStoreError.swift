//
//  PersistenceStoreError.swift
//  Pods
//
//  Created by Jan Bartel on 09.05.17.
//
//

import Foundation

public enum PersistenceStoreError : Error{
    case cannotUse(value: Any, withStoreForType: Any.Type)
    case cannotUseType(value: Any.Type, withStoreForType: Any.Type)
}

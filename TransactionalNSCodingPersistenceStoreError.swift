//
//  TransactionalNSCodingPersistenceStoreError.swift
//  CocoaLumberjack
//
//  Created by Mitja Neufeld on 13.11.18.
//

import Foundation

public enum TransactionalNSCodingPersistenceStoreError: Error {
    case NoWriteTransactionFound
    case CannotAddViewInTransaction(viewName: String)
    case CannotOpenAnTransactionInAnOtherTransaction
}

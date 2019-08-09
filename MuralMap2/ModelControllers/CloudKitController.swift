//
//  CloudKitController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation
import CloudKit
class CloudKitController {
    
    static let shared = CloudKitController()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD
    // Create
    func save(record: CKRecord, database: CKDatabase, completion: @escaping (CKRecord?) -> Void) {
        // save the record passed in, complete with an optional error
        database.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
            }
            print(#function)
            completion(record)
        }
    }
    
    // Read
    func fetchRecordsOf(type: String, database: CKDatabase, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        // Conditions of query, conditions to be return all found values
        let predicate = NSPredicate(value: true)
        // defines the record type we want to find, applies our predicate conditions
        let query = CKQuery(recordType: type, predicate: predicate)
        // Perform query, complete with our optional records and optional error
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(nil, error)
            }
            if let records = records {
                completion(records, nil)
            }
        }
    }
    
    func fetchSingleRecord(ofType type: String, with predicate: NSPredicate, database: CKDatabase, completion: @escaping ([CKRecord]?) -> Void) {
        
        let query = CKQuery(recordType: type, predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            print(#function)
            guard let records = records else { completion(nil) ; return}
            completion(records)
        }
        
    }
    
    func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserReferenceId, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            guard let recordID = appleUserReferenceId else {return}
            let appleUserReference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(appleUserReference)
        }
        
        
    }
    
    // Update
    func update(record: CKRecord, database: CKDatabase, completion: @escaping (Bool) -> Void) {
        let operation = CKModifyRecordsOperation()
        operation.recordsToSave = [record]
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.queuePriority = .high
        operation.completionBlock = {
            completion(true)
        }
        database.add(operation)
    }
    
    // Delete
    func delete(recordID: CKRecord.ID, database: CKDatabase, completion: @escaping (Bool) -> Void) {
        database.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
}


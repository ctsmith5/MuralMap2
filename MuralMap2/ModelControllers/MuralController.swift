//
//  MuralController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation
import CloudKit

class MuralController {
    
    static let shared = MuralController()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var savedMurals: [Mural] = []
    var userCommenting: String = ""
    let dispatchGroup = DispatchGroup()
    
    
    func saveMural(muralID: String, hasComment: Bool, completion: @escaping (Mural?) -> Void){
        
        let muralToSave = Mural(muralID: muralID)
        muralToSave.hasComment = hasComment
        let record = CKRecord(mural: muralToSave)
        
        publicDB.save(record) { (_, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(nil)
                return
            }
            self.savedMurals.append(muralToSave)
            completion(muralToSave)
        }
    }
    
    func saveComment(comment: Comment, mural: Mural, completion: @escaping(Bool) -> Void){
        
        let record = CKRecord(comment: comment)
        MuralController.shared.dispatchGroup.enter()
        publicDB.save(record) { (_, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(false)
            }
            completion(true)
        }
        
        MuralController.shared.dispatchGroup.leave()
        
    }
    
    func fetchMurals(completion: @escaping (Bool) -> Void ) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: MuralConstants.typeKey, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: MuralConstants.muralIDKey, ascending: true)]
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            guard let records = records else {completion(false) ; return}
            let murals = records.compactMap {(Mural(cloudkitRecord: $0))}
            self.savedMurals = murals
            completion(true)
        }
    }
    
    func fetchMuralByID(muralID: String, completion: @escaping (Mural?) -> Void){
        //This basically needs to take the StreetArt Object's MuralID and check to see if there is a cloudkit mural that matches that ID
        let predicate = NSPredicate(format: "MuralRegistrationID == %@", muralID)
        let query = CKQuery(recordType: MuralConstants.typeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(nil)
                return
            }
            guard let records = records else {completion(nil) ; return}
            if records.count > 0 {
                let muralRecord = records.first!
                let mural = Mural(cloudkitRecord: muralRecord)
                completion(mural)
            }else {
                completion(nil)
            }
        }
    }
    
    func fetchComments(mural: Mural, completion: @escaping ([Comment]) -> Void) {
        MuralController.shared.dispatchGroup.enter()
        //Might be on the right track
        let predicate = NSPredicate(format: "MuralReference == %@", mural.recordID )
        let query = CKQuery(recordType: CommentConstants.typeKey, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: CommentConstants.timeStampKey, ascending: true)]
        publicDB.perform(query, inZoneWith: nil) { (comments, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion([])
                return
            }
            guard let comments = comments else {completion([]) ; return}
            var commentArray: [Comment] = []
            for comment in comments {
                let newComment = Comment(cloudkitRecord: comment)
                guard let newFreakingComment = newComment else {return}
                commentArray.append(newFreakingComment)
            }
            completion(commentArray)
        }
        MuralController.shared.dispatchGroup.leave()
    }
}

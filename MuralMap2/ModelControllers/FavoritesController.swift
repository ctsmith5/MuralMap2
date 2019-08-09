//
//  FavoritesController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation
import CloudKit

class FavoritesController {
    
    static let shared = FavoritesController()
    let privateDB = CKContainer.default().privateCloudDatabase
    var favorites: [Favorite] = []
    
    func delete(){
        
    }
    
    func saveFavorites(muralID: String, title: String, completion: @escaping (Favorite?) -> Void){
        let favoriteToSave = Favorite(muralID: muralID, title: title)
        let record = CKRecord(favorite: favoriteToSave)
        
        privateDB.save(record) { (_, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(nil)
                return
            }
            completion(favoriteToSave)
        }
    }
    
    
    func fetchAllFavorites(completion: @escaping (Bool) -> Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: FavoriteConstants.typeKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(false)
                return
            }
            guard let records = records else {return}
            let favorites = records.compactMap {Favorite(cloudkitRecord: $0)}
            self.favorites = favorites
            completion(true)
        }
    }
    
    
    
    func fetchFavoriteslByID(muralID: String, completion: @escaping (Bool) -> Void){
        //This basically needs to take the StreetArt Object's MuralID and check to see if there is a cloudkit mural that matches that ID
        let predicate = NSPredicate(format: "MuralID == %@", muralID)
        let query = CKQuery(recordType: FavoriteConstants.typeKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                print("/n------/n")
                print(error.localizedDescription)
                completion(false)
                return
            }
            guard let records = records else {completion(false) ; return}
            
            let favoriteRecord = records.first
            if favoriteRecord != nil {
                completion(true)
            }else {
                completion(false)
            }
        }
    }
}

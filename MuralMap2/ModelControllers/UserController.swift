//
//  UserController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    var currentUser: User?
    
    func getFullName(){
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error) in
            if let error = error {
                print("\(error.localizedDescription)\(error) in function: \(#function)")
                
                return
            }
            
            if status == .denied {
                print("user denied")
            }
            CKContainer.default().fetchUserRecordID { (record, error) in
                if let error = error {
                    print("\(error.localizedDescription)\(error) in function: \(#function)")
                    
                    return
                }
                guard let record = record else {return}
                CKContainer.default().discoverUserIdentity(withUserRecordID: record, completionHandler: { (userID, error) in
                    print(userID?.hasiCloudAccount)
                    if let error = error {
                        print("\(error.localizedDescription)\(error) in function: \(#function)")
                        
                        return
                    }
                    
                    guard let unwrappedUserFirst = userID?.nameComponents?.givenName else {return}
                    guard let unwrappedUserLast = userID?.nameComponents?.familyName else {return}
                    
                    MuralController.shared.userCommenting = "\(unwrappedUserFirst) \(unwrappedUserLast)"
                })
            }
        }
    }
}

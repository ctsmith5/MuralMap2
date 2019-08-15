//
//  MuralCommentsTableViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import UIKit
import CloudKit
class MuralCommentsTableViewController: UITableViewController {
    
    
    var comments: [Comment] = []
    
    //MARK: - IB Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentsTextField: UITextField!
    
    @IBOutlet weak var newCommentActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var artistLabel: UILabel!
    
    var streetArt: CHIMural?{
        didSet{
            loadViewIfNeeded()
            updateUI()
        }
    }
    
    var mural: Mural?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let newMuralID = self.streetArt?.muralID else {return}
        getMuralInfo(muralID: newMuralID)
        
    }
    
    func getMuralInfo(muralID: String){
        MuralController.shared.fetchMuralByID(muralID: muralID) { (mural) in
            if let mural = mural {
                MuralController.shared.fetchComments(mural: mural) { (comments) in
                    self.comments = comments
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }else {
                print("actually just don't do anything and await further instructions")
            }
        }
    }
    
    func updateUI(){
        titleLabel.text = streetArt?.title
        artistLabel.text = streetArt?.artist
        
    }
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        guard let comments = mural?.comments else {return 0}
        
        return comments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? MuralCommentTableViewCell else {return UITableViewCell()}
        
        let comment = comments[indexPath.row]
        
        cell.userLabel.text = comment.user
        cell.timestampLabel.text = "\(comment.timeStamp.formatDate())"
        cell.contentLabel.text = comment.text
        
        //            cell.userLabel.text = "HardCoded User"
        //            cell.timestampLabel.text = mural?.comments[indexPath.row].timeStamp.formatDate()
        //            cell.contentLabel.text = mural?.comments[indexPath.row].text
        
        
        return cell
    }
    
    
    @IBAction func postCommentButtonPressed(_ sender: UIButton) {
        guard let newCommentContent = self.commentsTextField.text else {return}
        CKContainer.default().accountStatus { (accountStatus, error) in
            switch accountStatus {
            case .available:
                
                if MuralController.shared.userCommenting != "" {
                    
                    // New Comment Formatting
                    
                    //Grab text out of the textView
                    
                    // Guard against it being nil empty or containing "Leave a comment..."
                    
                    //Run all the shenanigans we figured out including the Activity Indicator
                    guard let art = self.streetArt else {return}
                    
                    MuralController.shared.fetchMuralByID(muralID: art.muralID) { (mural) in
                        if let mural = mural {
                            let muralReference = CKRecord.Reference(recordID: mural.recordID, action: .deleteSelf)
                            let newComment = Comment(text: newCommentContent, muralReference: muralReference, user: MuralController.shared.userCommenting)
                            
                            MuralController.shared.saveComment(comment: newComment, mural: mural) { (success) in
                                print("we successfully saved a comment on the dispatch group singleton")
                                
                                if success {
                                    DispatchQueue.main.async {
                                        self.newCommentActivityIndicator.startAnimating()
                                    }
                                    sleep(4)
                                    MuralController.shared.fetchComments(mural: mural) { (comments) in
                                        
                                        // Run after dispatch group clean
                                        
                                        MuralController.shared.dispatchGroup.notify(queue: .main) {
                                            self.comments = comments
                                            self.tableView.reloadData()
                                            self.newCommentActivityIndicator.stopAnimating()
                                        }
                                    }
                                }
                                else {
                                    print("no saveComments completion success")
                                }
                            }
                        }
                        else {
                            //if nil, initialize new mural and pass it into the save function
                            let newMural = Mural(muralID: art.muralID)
                            MuralController.shared.saveMural(muralID: newMural.muralID, hasComment: true) { (mural) in
                                //not sure why we need to complete with this
                                guard let mural = mural else {return}
                                let muralReference = CKRecord.Reference(recordID: mural.recordID, action: .deleteSelf)
                                let newComment = Comment(text: newCommentContent, muralReference: muralReference, user: MuralController.shared.userCommenting)
                                
                                MuralController.shared.saveComment(comment: newComment, mural: mural) { (success) in
                                    print("we successfully saved a comment")
                                    sleep(4)
                                    //Might need to present some Activity Indicator UI
                                    if success {
                                        MuralController.shared.fetchComments(mural: mural) { (comments) in
                                            MuralController.shared.dispatchGroup.notify(queue: .main) {
                                                self.comments = comments
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    else {
                                        print("no saveComments completion success")
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.commentsTextField.text = ""
                        self.commentsTextField.resignFirstResponder()
                    }
                }
                else{
                    let deniedAlert = UIAlertController(title: "Enable iCloud User Permissions", message: "In order to enable comments, ensure to Select YES to allow user lookup permissions. Otherwise commenting will not be permitted. Action cannot be undone.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    deniedAlert.addAction(okAction)
                    self.present(deniedAlert, animated: true) {
                        UserController.shared.getFullName()
                    }
                    
                }
                
            case .noAccount:
                DispatchQueue.main.async {
                    
                    let accountAlert = UIAlertController(title: "Comments Require iCloud", message: "Navigate to the settings menu in your iPhone and sign into iCloud in order to save favorites.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    accountAlert.addAction(okAction)
                    self.present(accountAlert, animated: true, completion: nil)
                }
            case .restricted:
                let accountAlert = UIAlertController(title: "Favorites Requires iCloud", message: "Navigate to the settings menu in your iPhone and sign into iCloud in order to save favorites.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                accountAlert.addAction(okAction)
                self.present(accountAlert, animated: true, completion: nil)
            case .couldNotDetermine:
                let accountAlert = UIAlertController(title: "Favorites Requires iCloud", message: "Navigate to the settings menu in your iPhone and sign into iCloud in order to save favorites.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                accountAlert.addAction(okAction)
                self.present(accountAlert, animated: true, completion: nil)
            }
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
} // End of MuralCommentsTableViewController Class

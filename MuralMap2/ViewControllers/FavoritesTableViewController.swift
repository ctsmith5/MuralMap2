//
//  FavoritesTableViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//


import UIKit

class FavoritesTableViewController: UITableViewController {
    var streetArt: CHIMural?
    @IBOutlet weak var favoritesActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FavoritesController.shared.fetchAllFavorites { (success) in
            if success {
                DispatchQueue.main.async {
                    self.favoritesActivityIndicator.startAnimating()
                }
                sleep(6)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.favoritesActivityIndicator.stopAnimating()
                }
            }
        }
        
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesController.shared.favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath)
        cell.textLabel?.text = FavoritesController.shared.favorites[indexPath.row].title
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as? MuralDetailViewController
            guard let chosenCell = tableView.indexPathForSelectedRow else {return}
            let selectedMural = FavoritesController.shared.favorites[chosenCell.row]
            let muralID = selectedMural.muralID
            guard let streetArt = self.streetArt else {return}
            destinationVC?.streetArt = streetArt
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var should: Bool?
        if identifier == "toDetailVC" {
            
            guard let chosenCell = tableView.indexPathForSelectedRow else {return false}
            let selectedMural = FavoritesController.shared.favorites[chosenCell.row]
            let muralID = selectedMural.muralID
            ChicagoClient.shared.selectMuralByID(registrationID: muralID) { (mural) in
                if let mural = mural {
                    self.streetArt = mural
                    should = true
                }else {
                    should = false
                }
            }
            
            DispatchQueue.main.async {
                self.favoritesActivityIndicator.startAnimating()
                sleep(4)
                self.favoritesActivityIndicator.stopAnimating()
            }
        }
        guard let shouldMaybe = should else { return false }
        return shouldMaybe
    }
    
    
}

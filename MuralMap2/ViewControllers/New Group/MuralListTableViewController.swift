//
//  MuralListTableViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import UIKit

class MuralListTableViewController: UITableViewController {
    
    @IBOutlet weak var muralSearchBar: UISearchBar!
    
    var streetArt: [CHIMural] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        muralSearchBar.delegate = self
        self.streetArt = ChicagoClient.shared.streetArt
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  streetArt.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "muralCell", for: indexPath) as? MuralListTableViewCell else { return UITableViewCell()}
        let mural = streetArt[indexPath.row]
        cell.streetArt = mural
        return cell
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as? MuralDetailViewController
            guard let chosenCell = self.tableView.indexPathForSelectedRow else {return}
            let chosenMural = streetArt[chosenCell.row]
            destinationVC?.streetArt = chosenMural
        }
    }
}//End of Class

extension MuralListTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {return}
        ChicagoClient.shared.queryMuralsByText(searchText: searchText) { (streetArt) in
            self.streetArt = streetArt
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ChicagoClient.shared.fetchMurals { (streetArt) in
            ChicagoClient.shared.streetArt = streetArt
            self.streetArt = streetArt
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


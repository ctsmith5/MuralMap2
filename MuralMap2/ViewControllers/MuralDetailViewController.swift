//
//  MuralDetailViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//


import UIKit
import CloudKit
class MuralDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var yearInstalledLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var artworkDescriptionLabel: UILabel!
    
    var football: Mural?
    
    var streetArt: CHIMural?{
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    var tour: Tour?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        
    }
    
    func updateViews(){
        titleLabel.text = streetArt?.title
        artistLabel.text = streetArt?.artist
        yearInstalledLabel.text = streetArt?.yearInstalled
        streetLabel.text = streetArt?.streetAddress
        artworkDescriptionLabel.text = streetArt?.artworkDescription
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TourController.shared.tours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addTourCell", for: indexPath)
        cell.textLabel?.text = TourController.shared.tours[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tour = TourController.shared.tours[indexPath.row]
    }
    
    @IBAction func addToFavoritesPressed(_ sender: UIButton) {
        guard let muralID = streetArt?.muralID,
            let title = streetArt?.title else {return}
        FavoritesController.shared.fetchFavoriteslByID(muralID: muralID) { (success) in
            if success {
                //You found it, don't save
                
            }
            else {
                //ain't got no favorite so go head and save it
                FavoritesController.shared.saveFavorites(muralID: muralID, title: title) { (favorite) in
                    
                    
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commentsButtonPressed(_ sender: UIButton) {
        UserController.shared.getFullName()
        //Check if user has granted discoverability permissions
        CKContainer.default().status(forApplicationPermission: .userDiscoverability) { (given, error) in
            if let error = error {
                print("\(error.localizedDescription)\(error) in function: \(#function)")
                return
            }
            if given == .granted {
                UserController.shared.getFullName()
            }
            if given == .denied {
                
            }
            
        }
        //If Yes, no problem go ahead and comment.
        
        
        
        //If No, tell them they are not allowed to comment until they do so. Giving them the option to continue to read comments but not have the ability to comment themselves.
        
        
        
    }
    
    
    @IBAction func addToToursButtonPressed(_ sender: UIButton) {
        //Present an AlertViewController that will display the tour list in a table view
        let tourAlert = UIAlertController(title: "Select a Tour", message: nil, preferredStyle: .alert)
        let tourTableView = UITableViewController()
        tourTableView.preferredContentSize = CGSize(width: 272, height: 176) // 4 default cell heights.
        tourAlert.setValue(tourTableView, forKey: "contentViewController")
        tourTableView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addTourCell")
        
        
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (add) in
            guard let mural = self.streetArt,
                var tour = self.tour else {return}
            TourController.shared.addToTour(tour: &tour, mural: mural)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            tourAlert.dismiss(animated: true, completion: nil)
        }
        
        tourAlert.addAction(cancelAction)
        tourAlert.addAction(addAction)
        
        present(tourAlert, animated: true) {
            tourTableView.tableView.dataSource = self
            tourTableView.tableView.delegate = self
            
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    //    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    //
    //        guard let muralID = streetArt?.muralID else {return false}
    //        MuralController.shared.fetchMuralByID(muralID: muralID) { (mural) in
    //            if let muralToPass = mural {
    //                self.football = muralToPass
    //            }else {
    //                guard let art = self.streetArt else {return}
    //                self.football = Mural(muralID: art.muralID )
    //            }
    //        }
    //        return true
    //    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentsView" {
            let destinationVC = segue.destination as? MuralCommentsTableViewController
            destinationVC?.streetArt = self.streetArt
            guard let newMuralID = self.streetArt?.muralID else {return}
            let newMural = Mural(muralID: newMuralID)
            destinationVC?.mural = newMural
            
            //Check icloud
            //fetch by mural ID
            
            
        }
        if segue.identifier == "toNavigationView" {
            let destinationVC = segue.destination as? NavigationViewController
            destinationVC?.streetArt = self.streetArt
        }
    }
}


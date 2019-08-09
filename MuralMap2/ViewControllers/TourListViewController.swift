//
//  TourListViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import UIKit

class TourListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tourTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tourTableView.delegate = self
        tourTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tourTableView.reloadData()
    }
    //MARK: - TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TourController.shared.tours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tourCell", for: indexPath) as? TourTableViewCell else {return UITableViewCell()}
        cell.tourNameLabel.text = TourController.shared.tours[indexPath.row].title
        cell.distanceLabel.text = "Distance: \(TourController.shared.tours[indexPath.row].length) miles"
        let murals = TourController.shared.tours[indexPath.row].streetArtwork
        cell.stopsLabel.text = "Stops: \(murals.count)"
        return cell
    }
    
    @IBAction func createNewTourButtonPressed(_ sender: UIButton) {
        let newTourController = UIAlertController(title: "Add New Tour", message: "Enter a name for the new tour you are creating", preferredStyle: .alert)
        newTourController.addTextField { (textField) in
            textField.placeholder = "Enter Tour Name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (add) in
            guard let textFields = newTourController.textFields else {return}
            guard let tourName = textFields[0].text else {return}
            TourController.shared.newTour(title: tourName)
            self.tourTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            newTourController.dismiss(animated: true, completion: nil)
        }
        newTourController.addAction(cancelAction)
        newTourController.addAction(addAction)
        
        present(newTourController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTourDetailView"{
            let destinationVC = segue.destination as? TourDetailViewController
            guard let chosenCell = self.tourTableView.indexPathForSelectedRow else {return}
            let chosenTour = TourController.shared.tours[chosenCell.row]
            destinationVC?.tour = chosenTour
        }
    }
    
    
}

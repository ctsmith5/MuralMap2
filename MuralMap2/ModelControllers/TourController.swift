//
//  TourController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation

class TourController {
    
    static let shared = TourController()
    
    var tours: [Tour] = []
    
    //CRUD Functions
    func newTour(title: String){
        let newTour = Tour(title: title, description: "", length: 0.0, streetArtwork: [])
        self.tours.append(newTour)
    }
    func addToTour(tour: inout Tour, mural: CHIMural){
        tour.streetArtwork.append(mural)
    }
    
    func deleteTour(tour: Tour){
        
    }
    
    func fileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileName = "tours.json"
        let documentsDirectoryURL = urls[0].appendingPathComponent(fileName)
        return documentsDirectoryURL
    }
    
    /*
     func saveToPersistentStore(){
     let encoder = JSONEncoder()
     do{
     let data = try encoder.encode(tours)
     try data.write(to: fileURL())
     }catch let error{
     print("Error saving to persistent storage \(error.localizedDescription)")
     }
     }
     func loadFromPersistentStore(){
     let decoder = JSONDecoder()
     do{
     let data = try Data(contentsOf: fileURL())
     let people = try decoder.decode([Tour].self, from: data)
     self.persons = people
     }catch{
     print("Error loading from persistent storage \(error.localizedDescription)")
     }
     }
     */
    
}

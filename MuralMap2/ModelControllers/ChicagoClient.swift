//
//  ChicagoClient.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation

class ChicagoClient {
    
    
    let keyID = "8uj3wugj1jv0rhejrlfm3pumw"
    let secret = "2tdyp6wq94snutllbp0uc65hrdg9imcxsv2znrqs51y0wgtyyi"
    static let shared = ChicagoClient()
    let baseURL = URL(string: "https://data.cityofchicago.org/resource/we8h-apcf.json")
    
    var streetArt: [CHIMural] = []
    
    func queryMuralsByText(searchText: String, completion: @escaping ([CHIMural]) -> Void){
        guard let url = baseURL else {return}
        
        let query = URLQueryItem(name: "$q", value: searchText)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [query]
        guard let finalUrl = urlComponents?.url else {return}
        
        var urlRequest = URLRequest(url: finalUrl)
        urlRequest.httpMethod = "GET"
        urlRequest.httpBody = nil
        
        URLSession.shared.dataTask(with: finalUrl) { (data, _, error) in
            
            if let error = error {
                print(" \(error.localizedDescription) \(error) in function \(#function)")
                completion([])
                return
            }
            guard let data = data else {return}
            do{
                let streetArt = try JSONDecoder().decode([CHIMural].self, from: data)
                completion(streetArt)
                
                
            }catch{
                print("could not load from dictionary \(error.localizedDescription)")
                completion([])
            }
            }.resume()
    }
    
    func selectMuralByID(registrationID: String, completion: @escaping (CHIMural?) -> Void){
        guard let url = baseURL else {return}
        
        let query = URLQueryItem(name: "mural_registration_id", value: registrationID)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [query]
        guard let finalUrl = urlComponents?.url else {return}
        
        var urlRequest = URLRequest(url: finalUrl)
        urlRequest.httpMethod = "GET"
        urlRequest.httpBody = nil
        
        URLSession.shared.dataTask(with: finalUrl) { (data, _, error) in
            
            if let error = error {
                print(" \(error.localizedDescription) \(error) in function \(#function)")
                completion(nil)
                return
            }
            guard let data = data else {return}
            do{
                let mural = try JSONDecoder().decode(CHIMural.self, from: data)
                completion(mural)
                
                
            }catch{
                print("could not load from dictionary \(error.localizedDescription)")
                completion(nil)
            }
            }.resume()
    }
    
    func fetchMurals(completion: @escaping ([CHIMural]) -> Void){
        guard let url = baseURL else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.httpBody = nil
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(" \(error.localizedDescription) \(error) in function \(#function)")
                completion([])
                return
            }
            guard let data = data else {return}
            do{
                let murals = try JSONDecoder().decode([CHIMural].self, from: data)
                completion(murals)
            }catch{
                print(error)
            }
            }.resume()
    }
    
    
}

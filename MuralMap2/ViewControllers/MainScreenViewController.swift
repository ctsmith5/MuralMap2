//
//  MainScreenViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

//
//  MainScreenViewController.swift
//  CityArt
//
//  Created by Colin Smith on 6/19/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


// TODO: - Email info@muralarts.org about Philly Access

class MainScreenViewController: UIViewController {
    
    var locations: [CLLocation] = []
    var selectedAnnotation: MKAnnotation?
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private let chicago: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 41.874338, longitude: -87.647154)
    private let chicagoArea: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.874338, longitude:  -87.647154), latitudinalMeters: 70000, longitudinalMeters: 70000)
    
    
    @IBOutlet weak var muralMapView: MKMapView!
    
    
    var streetArt: [CHIMural] = []
    
    //MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MuralController.shared.fetchMurals { (success) in
            print("Successfully fetched Murals from CloudKit")
        }
        muralMapView.delegate = self
        
        ChicagoClient.shared.fetchMurals { (streetArt) in
            ChicagoClient.shared.streetArt = streetArt
            self.streetArt = streetArt
            self.getLocations()
        }
        self.muralMapView.setCenter(chicago, animated: false)
        self.muralMapView.setRegion(chicagoArea, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        ChicagoClient.shared.fetchMurals { (streetArt) in
            ChicagoClient.shared.streetArt = streetArt
            self.streetArt = streetArt
            self.getLocations()
        }
        self.muralMapView.setCenter(chicago, animated: false)
        self.muralMapView.setRegion(chicagoArea, animated: true)
    }
    
    //MARK: - MapKit Functions
    func getLocations(){
        
        let muralArray = self.streetArt
        let locationArray = muralArray.map { (streetArt) -> CLLocation in
            guard let lat = streetArt.latitude?.degreeValue,
                let long = streetArt.longitude?.degreeValue else {return CLLocation()}
            self.locations.append(CLLocation(latitude: lat, longitude: long))
            return CLLocation(latitude: lat, longitude: long)
        }
        self.locations = locationArray
        muralMapView.addAnnotations(streetArt)
        
        
    }
    
    func configureLocationServices(){
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status  == . notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }else if status == .authorizedAlways || status == .authorizedWhenInUse{
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Navigation
    
    @objc func showAnnotationDetail(){
        performSegue(withIdentifier: "toDetailVC"){
            
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let destinationVC = segue.destination as? MuralDetailViewController else {return}
            destinationVC.streetArt = selectedAnnotation as? CHIMural
            
        }
    }
}// End of ViewController Class

//MARK: - Extensions
extension MainScreenViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CHIMural else {return nil}
        self.selectedAnnotation = annotation
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
            button.addTarget(self, action: #selector(showAnnotationDetail), for: .touchUpInside)
            view.markerTintColor = UIColor(hue: 226/360, saturation: 0.62, brightness: 0.77, alpha: 1.0)
        }
        return view
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Latest Loc")
        guard let latestLocation = locations.first else {return}
        currentCoordinate = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Status Changed")
    }
    
}// End of Class

//MARK: - Extensions
extension String {
    var degreeValue: CLLocationDegrees {
        return (self as NSString).doubleValue
    }
}



extension MainScreenViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        muralMapView.removeAnnotations(self.streetArt)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {return}
        ChicagoClient.shared.queryMuralsByText(searchText: searchText) { (murals) in
            self.streetArt = murals
            self.getLocations()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ChicagoClient.shared.fetchMurals { (murals) in
            ChicagoClient.shared.streetArt = murals
            self.streetArt = murals
            self.getLocations()
        }
        self.muralMapView.setCenter(chicago, animated: false)
        self.muralMapView.setRegion(chicagoArea, animated: true)
    }
}


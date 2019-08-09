//
//  NavigationViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

class NavigationViewController: UIViewController {
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var navigationMapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
    var currentCoordinate = CLLocationCoordinate2D()
    
    
    var streetArt: CHIMural?
    
    private let chicago: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 41.874338, longitude: -87.647154)
    private let chicagoArea: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.874338, longitude:  -87.647154), latitudinalMeters: 70000, longitudinalMeters: 70000)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerMapAnnotationViews()
        navigationMapView.delegate = self
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        setupLocationManager()
        checkLocationServices()
        locationManager.startUpdatingLocation()
        navigationMapView.setRegion(chicagoArea, animated: true)
        navigationMapView.showsUserLocation = true
        navigationMapView.centerCoordinate = currentCoordinate
        guard let destinationCoord = streetArt?.coordinate else {return}
        getDirections(to: destinationCoord)
        createAnnotation()
    }
    
    var stepsToDestination: [MKRoute.Step] = []{
        didSet{
            self.stepsTableView.reloadData()
        }
    }
    
    func checkCoordinate() {
        //if current coordinate is within the Chicago Area. Don't do anything
        //if current coordinate is outside of the Chicago Area, notify user and option to pretend
        
        if currentCoordinate.longitude > -88.5001510 && currentCoordinate.longitude < -86.7812235 &&
            currentCoordinate.latitude > 41.1634858 && currentCoordinate.latitude < 42.2808025 {
            //Congrats. You are inside Chicago. No problem Carry On.
        }else {
            let outsiderAlertController = UIAlertController(title: "You are outside of the Chicago Area", message: "For a smoother experience the map will show a position for you inside Chicago", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "OK", style: .default) { (yes) in
                // manipulate the phone's location somehow
                let randomChicagoSpot = CLLocationCoordinate2D(latitude: 41.881967, longitude: -87.632363)
                let annotation = FakeLocationAnnotation()
                self.locationManager.stopUpdatingLocation()
                self.currentCoordinate = randomChicagoSpot
                self.navigationMapView.addAnnotation(annotation)
                self.navigationMapView.showsUserLocation = false
                guard let destinationCoord = self.streetArt?.coordinate else {return}
                self.getDirections(to: destinationCoord)
            }
            
            
            outsiderAlertController.addAction(yesAction)
            
            present(outsiderAlertController, animated: true, completion: nil)
        }
        
        
    }
    func registerMapAnnotationViews(){
        navigationMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(FakeLocationAnnotation.self))
        navigationMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CHIMural.self))
    }
    
    func createAnnotation(){
        guard let streetArt = streetArt else {return}
        navigationMapView.addAnnotation(streetArt)
        
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        }else{
            // Ask for location again
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            // Best Case
            break
        case .authorizedAlways:
            break
        case .denied:
            // Show Alert to help them back to permissions
            locationManager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            
            break
        case .restricted:
            break
        default :
            //I dunno
            break
        }
        
    }
    
    
    //You might get an error here due to the map having MKAnnotations not MKMapItems
    func getDirections(to destination: CLLocationCoordinate2D){
        //obviously here we have hardcoded a location in chicago in lieu of the actual location
        
        let source = MKPlacemark(coordinate: currentCoordinate)
        
        let sourceMapItem = MKMapItem(placemark: source)
        
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        directionsRequest.destination = destinationItem
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate { (response, error) in
            if let error = error {
                print("There was an error calculating the directions to destination")
                print(error)
                print("\n --------\n")
                print(error.localizedDescription)
            }
            guard let response = response else {return}
            let primaryRoute = response.routes[0]
            
            self.navigationMapView.addOverlay(primaryRoute.polyline)
            self.stepsToDestination = primaryRoute.steps
            self.stepsToDestination.remove(at: 0)
            self.distanceLabel.text = "Total Distance: \(primaryRoute.distance/1000) km"
            self.navigationMapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: false)
            
            self.zoomMap()
        }
    }
    func zoomMap() {
        var region: MKCoordinateRegion = self.navigationMapView.region
        var span: MKCoordinateSpan = navigationMapView.region.span
        span.longitudeDelta *= 2.5
        span.latitudeDelta *= 1.5
        region.span = span
        
        
        navigationMapView.setRegion(region, animated: true)
    }
}// End of Class


extension NavigationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let currentLocation = locations.first else {return}
        currentCoordinate = currentLocation.coordinate
        navigationMapView.userTrackingMode = .followWithHeading
        checkCoordinate()
    }
    
    
}

extension NavigationViewController: MKMapViewDelegate {
    
    
    //View For Method. Set up each of the two types of Annotation here
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? FakeLocationAnnotation {
            annotationView = fakeLocationAnnotationView(for: annotation, on: mapView)
        }else if let annotation = annotation as? CHIMural {
            annotationView = setupDestinationAnnotation(for: annotation, on: mapView)
        }
        return annotationView
    }
    
    //Helper Functions for setting up the MKAnnotationViews
    
    private func fakeLocationAnnotationView(for annotation: FakeLocationAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(FakeLocationAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = false
            markerAnnotationView.markerTintColor = UIColor.red
        }
        return view
    }
    
    private func setupDestinationAnnotation(for annotation: CHIMural, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(CHIMural.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = false
            markerAnnotationView.markerTintColor = UIColor(hue: 226/360, saturation: 0.62, brightness: 0.77, alpha: 1.0)
        }
        return view
    }
    
    
    
    
    //Polyline Renderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 8
            return renderer
        }
        return MKPolylineRenderer()
    }
} // End of MapViewDelegate Extension



extension NavigationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsToDestination.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell", for: indexPath) as? NavigationStepsTableViewCell else {return UITableViewCell()}
        if stepsToDestination[indexPath.row].instructions != ""{
            cell.distanceLabel.text = stepsToDestination[indexPath.row].instructions
            cell.metersLabel.text = stepsToDestination[indexPath.row].distance.asString()
        }
        return cell
    }
}

extension CLLocationDistance {
    func asString() -> String{
        let distance = Double(self)
        let stringOfDistance = "\(distance) m"
        return stringOfDistance
    }
}


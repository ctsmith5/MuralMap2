//
//  TourDetailViewController.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//


import UIKit
import MapKit
class TourDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var muralListTableView: UITableView!
    @IBOutlet weak var tourMapView: MKMapView!
    
    @IBOutlet weak var muralCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    private let chicago: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 41.874338, longitude: -87.647154)
    private let chicagoArea: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.874338, longitude:  -87.647154), latitudinalMeters: 70000, longitudinalMeters: 70000)
    
    var locations: [CLLocation] = []
    //  var coordinates: [CLLocationCoordinate2D] = []
    var tour: Tour? {
        didSet{
            loadViewIfNeeded()
            updateViews()
            
        }
    }
    var selectedAnnotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tourMapView.delegate = self
        muralListTableView.delegate = self
        muralListTableView.dataSource = self
        titleTextField.text = tour?.title
        if tour?.description != nil {
            descriptionTextView.text = tour?.description
        }else {
            descriptionTextView.text = ""
        }
        plotMurals()
        self.tourMapView.setCenter(chicago, animated: false)
        self.tourMapView.setRegion(chicagoArea, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        getDirections()
    }
    
    @objc func showAnnotationDetail(){
        performSegue(withIdentifier: "toDetailVC"){
            
        }
    }
    
    func updateViews(){
        titleTextField.text = tour?.title
        if tour?.description != nil {
            descriptionTextView.text = tour?.description
        }else {
            descriptionTextView.text = ""
        }
        guard let tour = tour else {return}
        
        muralCountLabel.text = "Murals: \(tour.streetArtwork.count)"
        
        //        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        //        tourMapView.addOverlay(polyline)
        
    }
    //MARK: - MapView Functions
    func plotMurals(){
        guard let tour = tour else {return}
        let muralArray = tour.streetArtwork
        let locationArray = muralArray.map { (mural) -> CLLocation in
            guard let lat = mural.latitude?.degreeValue,
                let long = mural.longitude?.degreeValue else {return CLLocation()}
            self.locations.append(CLLocation(latitude: lat, longitude: long))
            return CLLocation(latitude: lat, longitude: long)
        }
        self.locations = locationArray
        tourMapView.addAnnotations(tour.streetArtwork)
        getDistance { (distance) in
            self.distanceLabel.text = "Total Distance: \(distance) miles"
        }
        //        let coordinates = muralArray.map { (mural) -> CLLocationCoordinate2D in
        //            guard let lat = mural.latitude?.degreeValue,
        //                let long = mural.longitude?.degreeValue else {return CLLocationCoordinate2D()}
        //            self.coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: long))
        //             return CLLocationCoordinate2D(latitude: lat, longitude: long)
        //        }
        
    }
    
    func getDirections(){
        let request = createDirectionsRequest()
        let directions = MKDirections(request: request)
        directions.calculate {(response, error) in
            if let error = error {
                print(error)
            }
            guard let response = response else {return}
            self.tourMapView.addOverlay(response.routes[0].polyline)
            self.tourMapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: false)
        }
    }
    
    func calculateDistancefrom(sourceLocation: MKMapItem, destinationLocation: MKMapItem, doneSearching: @escaping (_ expectedTravelTim: TimeInterval) -> Void) {
        
        let request: MKDirections.Request = MKDirections.Request()
        
        request.source = sourceLocation
        request.destination = destinationLocation
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { (directions, error) in
            
            if var routeResponse = directions?.routes {
                routeResponse.sort(by: {$0.expectedTravelTime <
                    $1.expectedTravelTime})
                let quickestRouteForSegment: MKRoute = routeResponse[0]
                self.tour?.length = round(100*(quickestRouteForSegment.distance)*0.000621371)/100
                doneSearching(round(100*(quickestRouteForSegment.distance)*0.000621371)/100)
                
            }
        }
    }
    
    func getDistance(completion: @escaping (_ distance: Double) -> Void) {
        guard let tour = tour else {return}
        guard let last = tour.streetArtwork.last?.coordinate,
            let first = tour.streetArtwork.first?.coordinate else {return}
        
        let destinationItem =  MKMapItem(placemark: MKPlacemark(coordinate: last))
        
        let sourceItem =  MKMapItem(placemark: MKPlacemark(coordinate: first))
        
        self.calculateDistancefrom(sourceLocation: sourceItem, destinationLocation: destinationItem, doneSearching: { distance in
            completion(distance)
        })
    }
    
    func createDirectionsRequest() -> MKDirections.Request{
        
        guard let tour = tour else {return MKDirections.Request()}
        guard let last = tour.streetArtwork.last?.coordinate,
            let first = tour.streetArtwork.first?.coordinate else {return MKDirections.Request()}
        //FIXME: - This only supports first and last waypoints in the mural array
        
        let destination = MKPlacemark(coordinate: last)
        let source = MKPlacemark(coordinate: first)
        let request =  MKDirections.Request()
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        return request
        
    }
    //MARK: TableView DataSource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tour = tour else {return 0}
        return tour.streetArtwork.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "muralListCell", for: indexPath)
        guard let tour = tour else {return UITableViewCell()}
        cell.textLabel?.text = tour.streetArtwork[indexPath.row].title
        return cell
    }
}

//MARK: - MapView Delegate Methods

extension TourDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
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
            let button = UIButton(type: .contactAdd)
            view.rightCalloutAccessoryView = button
            button.addTarget(self, action: #selector(showAnnotationDetail), for: .touchUpInside)
            view.markerTintColor = UIColor(hue: 226/360, saturation: 0.62, brightness: 0.77, alpha: 1.0)
        }
        return view
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as? MuralDetailViewController
            guard let chosenCell = self.muralListTableView.indexPathForSelectedRow else {return}
            guard let tour = tour else {return}
            let chosenMural = tour.streetArtwork[chosenCell.row]
            destinationVC?.streetArt = chosenMural
        }
    }
}





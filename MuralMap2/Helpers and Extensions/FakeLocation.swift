//
//  FakeLocation.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import MapKit

class FakeLocationAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D(latitude: 41.881967, longitude: -87.632363)
    
    var title: String? = "Current Location"
}

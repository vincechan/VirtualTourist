//
//  MapPin.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/10/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import MapKit

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin : Pin?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(pin : Pin) {
        self.pin = pin
        self.coordinate = pin.getCoordiate()
    }
}
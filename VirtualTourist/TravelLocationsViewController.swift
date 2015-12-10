//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/6/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var droppedPin : MapPin?
    
    override func viewDidLoad() {
        mapView.delegate = self
       
        // setup map view long press recognizer
        let recognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        recognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(recognizer)
        
        let pins = fetchAllPins()
        var mapPins = [MapPin]()
        for pin in pins {
            let mapPin = MapPin(pin: pin)
            mapPins.append(mapPin)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(mapPins)
        }
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            return try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error in fetchAllPins(): \(error)")
            return [Pin]()
        }
    }
    
    func handleLongPress(sender: UIGestureRecognizer) {
        print("handleLongPress \(sender.state.rawValue)")

        
        if sender.state == .Began {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoord = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            droppedPin = MapPin(coordinate: touchCoord)
            self.mapView.addAnnotation(self.droppedPin!)
        }
        else if sender.state == .Changed {
            if let pin = droppedPin {
                let touchPoint = sender.locationInView(self.mapView)
                let touchCoord = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
                pin.coordinate = touchCoord
            }
        }
        else if sender.state == .Ended {
            if let pin = droppedPin {
                let touchPoint = sender.locationInView(self.mapView)
                let touchCoord = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
                pin.coordinate = touchCoord
                
                _ = Pin(longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotaionView")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            view?.draggable = true
        }
        return view
    }
}

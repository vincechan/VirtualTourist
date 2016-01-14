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
    
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    let latitudeDelatKey = "latitudeDelta"
    let longitudeDeltaKey = "longitudeDelta"
    let savedLocationKey = "savedLocationKey"
    var droppedPin : PinAnnotation?
    var preference: Preference?
    
    override func viewDidLoad() {
        mapView.delegate = self
        
        // setup map view long press recognizer
        let recognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        recognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(recognizer)
        
        let pins = fetchAllPins()
        var annotations = [PinAnnotation]()
        for pin in pins {
            let annotation = PinAnnotation(pin: pin)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        
        loadMapRegion()
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
        if sender.state == .Began {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoord = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            droppedPin = PinAnnotation(coordinate: touchCoord)
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
                
                pin.pin  = Pin(longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                CoreDataStackManager.sharedInstance().saveContext()
                
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("didSelectAnnotationView")
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        controller.pin = (view.annotation as! PinAnnotation).pin
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChange")
        saveMapRegion()
    }
    
    func loadMapRegion() {
        preference = Preference.loadPreference()
        if preference != nil {
            let span = MKCoordinateSpan(
                latitudeDelta: preference!.latitudeDelta,
                longitudeDelta: preference!.longitudeDelta)
            let center = CLLocationCoordinate2DMake(
                preference!.latitude,
                preference!.longitude)
            let region = MKCoordinateRegionMake(center, span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func saveMapRegion() {
        if (preference == nil) {
            preference = Preference(
                longitude: mapView.region.center.longitude, latitude: mapView.region.center.latitude,
                longitudeDelta: mapView.region.span.longitudeDelta, latitudeDelta: mapView.region.span.latitudeDelta,
                context: CoreDataStackManager.sharedInstance().managedObjectContext)
        }
        else {
            preference!.longitude = mapView.region.center.longitude
            preference!.latitude = mapView.region.center.latitude
            preference!.longitudeDelta = mapView.region.span.longitudeDelta
            preference!.latitudeDelta = mapView.region.span.latitudeDelta
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

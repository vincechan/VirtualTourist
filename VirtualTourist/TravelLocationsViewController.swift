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
        print("handleLongPress \(sender.state.rawValue)")
        
        
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
        let savedLocation = NSUserDefaults.standardUserDefaults().boolForKey(savedLocationKey)
        if savedLocation {
            let span = MKCoordinateSpan(
                latitudeDelta: NSUserDefaults.standardUserDefaults().doubleForKey(latitudeDelatKey),
                longitudeDelta: NSUserDefaults.standardUserDefaults().doubleForKey(longitudeDeltaKey))
            let center = CLLocationCoordinate2DMake(
                NSUserDefaults.standardUserDefaults().doubleForKey(latitudeKey),
                NSUserDefaults.standardUserDefaults().doubleForKey(longitudeKey))
            let region = MKCoordinateRegionMake(center, span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func saveMapRegion() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: savedLocationKey)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: latitudeKey)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: longitudeKey)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: latitudeDelatKey)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: longitudeDeltaKey)
    }
    
}

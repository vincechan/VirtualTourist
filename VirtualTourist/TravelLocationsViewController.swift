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
    
    var droppedPin : PinAnnotation?
    
    // to persist center of map and zoom level
    var preference: Preference?
    
    var cancelDownload = false
    
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
    
    override func viewWillAppear(animated: Bool) {
        cancelDownload = false
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            showError("Error in fetchAllPins(): \(error)")
            return [Pin]()
        }
    }
    
    func handleLongPress(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            let touchPoint = sender.locationInView(mapView)
            let touchCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            droppedPin = PinAnnotation(coordinate: touchCoord)
            mapView.addAnnotation(droppedPin!)
        }
        else if sender.state == .Changed {
            if let pin = droppedPin {
                let touchPoint = sender.locationInView(mapView)
                let touchCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                pin.coordinate = touchCoord
            }
        }
        else if sender.state == .Ended {
            if let pin = droppedPin {
                let touchPoint = sender.locationInView(mapView)
                let touchCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                pin.coordinate = touchCoord
                
                pin.pin  = Pin(longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                CoreDataStackManager.sharedInstance().saveContext()
                
                // download photos as soon as pin is dropped
                downloadPhotos(pin.pin!)
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        // signal to cancel download in case there is a download in progress in background thread
        cancelDownload = true
        
        controller.pin = (view.annotation as! PinAnnotation).pin
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // save the map center and zoom level as soon as the map region has changed
        saveMapRegion()
    }
    
    // download photos from flickr into local cache
    func downloadPhotos(pin: Pin) {
        FlickrClient.sharedInstance().getPhotos(pin.latitude, longitude: pin.longitude) {
            (result, error) in
            if (error != nil) {
                self.showError("download photos error: \(error)")
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    if (!self.cancelDownload) {
                        let photos = Photo.photosFromResult(result, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                        for photo in photos {
                            photo.pin = pin
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
                
            }
        }
    }
    
    // restore map center and zoom level
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
    
    // save map center and zoom level
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
    
    // Show an error message with alert
    func showError(error: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

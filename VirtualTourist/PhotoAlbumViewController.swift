//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/11/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin : Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin!.getCoordinate()
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegionMake(pin!.getCoordinate(), span)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
}

//
//  Pin.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/9/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import CoreData
import MapKit

class Pin : NSManagedObject {
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(longitude: Double, latitude : Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

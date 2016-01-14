//
//  Preference.swift
//  VirtualTourist
//
//  Created by Vince Chan on 1/13/16.
//  Copyright © 2016 Vince Chan. All rights reserved.
//
import CoreData
import MapKit

// Preference is used to persist map center and zoom level
class Preference : NSManagedObject {
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var latitudeDelta : Double
    @NSManaged var longitudeDelta : Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(longitude: Double, latitude : Double, longitudeDelta: Double, latitudeDelta: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Preference", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    // retrieve preference from CoreData
    static func loadPreference()-> Preference? {
        var preference : Preference?
        do {
            let fetchRequest = NSFetchRequest(entityName: "Preference")
            fetchRequest.fetchLimit = 1
            if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest) as? [Preference] {
                if (results.count > 0) {
                    preference = results[0]
                }
            }
        } catch {
        }
        return preference
    }
}

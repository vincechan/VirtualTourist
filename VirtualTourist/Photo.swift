//
//  Photo.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/9/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import CoreData
import UIKit

class Photo : NSManagedObject {
    
    struct Keys {
        static let Url = "url_m"
        static let ID = "id"
    }
    
    @NSManaged var id: String
    @NSManaged var imageUrl: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    
        id = dictionary[Keys.ID] as! String
        imageUrl = dictionary[Keys.Url] as! String
    }
    
    // Given an array of dictionaries, convert them to an array of Photo objects
    static func photosFromResult(results: [[String: AnyObject]]) -> [Photo] {
        var photos = [Photo]()
        
        let tempContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        tempContext.parentContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        for result in results {
            photos.append(Photo(dictionary: result, context: tempContext))
        }
        
        return photos
    }
    
    
    var photoImage: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(id)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: id)
        }
    }
}

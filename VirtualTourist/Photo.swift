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
    @NSManaged var localPath: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as! String
        imageUrl = dictionary[Keys.Url] as! String
        localPath = pathForIdentifier(id)
    }
    
    var photoImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithPath(localPath)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withPath: localPath)
        }
    }
    
    // parse the flickr api result into an array of photo objects
    static func photosFromResult(result: AnyObject, context: NSManagedObjectContext) -> [Photo]{
        var photos = [Photo]()
        
        if let photosResult = result["photos"] as? NSDictionary {
            if let photosArray = photosResult["photo"] as? [[String: AnyObject]] {
                for dict in photosArray {
                    let photo = Photo(dictionary: dict, context: context)
                    photos.append(photo)
                }
            }
        }
        return photos
    }
    
    // delete a photo managed object along with the physical image file
    func delete() {
        // delete physical file
        FlickrClient.Caches.imageCache.storeImage(nil, withPath: localPath)
        
        // delete from core data
        CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(self)
    }
    
    // determine a photo's image file path given its identifier
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}

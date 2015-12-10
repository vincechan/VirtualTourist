//
//  Photo.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/9/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import CoreData

class Photo : NSManagedObject {
    
    @NSManaged var imagePath : String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}

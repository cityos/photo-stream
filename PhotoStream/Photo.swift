//
//  Photo.swift
//  PhotoStream
//
//  Created by Said Sikira on 5/5/15.
//
//

import CoreData

class Photo : NSManagedObject {
    @NSManaged var image: NSData?
    @NSManaged var state: NSNumber
    @NSManaged var url: String
}
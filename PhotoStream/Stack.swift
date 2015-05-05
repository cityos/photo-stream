//
//  CacheStack.swift
//  CityOSPhoto
//
//  Created by Said Sikira on 5/4/15.
//  Copyright (c) 2015 Said Sikira. All rights reserved.
//

import Foundation
import CoreData

/// Defines a Core Data stack used for caching
class CacheDataStack {
    
    let context : NSManagedObjectContext!
    let persistentStoreCoordinator : NSPersistentStoreCoordinator!
    let model : NSManagedObjectModel!
    let store : NSPersistentStore!
    
    init() {
        let fileManager = NSFileManager.defaultManager()
        let URLS = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as! [NSURL]
        let documentsDirectory = URLS[0]
        
        let bundle = NSBundle.mainBundle()
        self.model = CacheModel.photoModel
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        self.context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        let storeURL = documentsDirectory.URLByAppendingPathComponent("PhotoStream.sqlite")
        
        let storeOptions = [ NSMigratePersistentStoresAutomaticallyOption : true ]
        
        var error : NSError?
        
        self.store = persistentStoreCoordinator.addPersistentStoreWithType(
            NSSQLiteStoreType,
            configuration: nil,
            URL: storeURL,
            options: storeOptions,
            error: &error)
        
        if store == nil {
            println("Persistent store error \(error)")
            abort()
        }
    }
    
    func saveCache() {
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            println("Could not save: \(error), \(error?.userInfo)") }
    }
}
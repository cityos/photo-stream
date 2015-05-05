//
//  PhotoObjectModel.swift
//  PhotoStream
//
//  Created by Said Sikira on 5/5/15.
//
//

import Foundation
import CoreData

final class CacheModel {
    
    /// Returns defined PhotoModel
    class var photoModel : NSManagedObjectModel {
        var model = NSManagedObjectModel()
        var entity = NSEntityDescription()
        entity.name = "Photo"
        entity.managedObjectClassName = "PhotoStream.Photo"
        
        var properties = NSMutableArray()
        
        var urlProperty = NSAttributeDescription()
        urlProperty.name = "url"
        urlProperty.attributeType = NSAttributeType.StringAttributeType
        urlProperty.optional = false
        urlProperty.indexed = true
        properties.addObject(urlProperty)
        
        var stateProperty = NSAttributeDescription()
        stateProperty.name = "state"
        stateProperty.attributeType = NSAttributeType.Integer16AttributeType
        stateProperty.optional = true
        stateProperty.indexed = false
        properties.addObject(stateProperty)
        
        var imageProperty = NSAttributeDescription()
        imageProperty.name = "image"
        imageProperty.attributeType = NSAttributeType.BinaryDataAttributeType
        imageProperty.allowsExternalBinaryDataStorage = true
        imageProperty.optional = true
        imageProperty.indexed = false
        properties.addObject(imageProperty)
        
        entity.properties = properties as [AnyObject]
        model.entities = [entity]
        return model
    }
}
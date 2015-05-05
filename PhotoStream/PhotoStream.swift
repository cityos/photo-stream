//
//  PhotoStream.swift
//  CityOS
//
//  Created by Said Sikira on 5/5/15.
//
//

import Foundation
import CoreData
import UIKit

enum PhotoState : NSNumber {
    case Failed = 0
    case New = 1
    case Downloaded = 2
    case Cached = 3
}

/// Defines a stream that enables fast photo caching and downloading
public final class PhotoStream {
    
    public init() {}
    
    static var stack = CacheDataStack()
    
    /// NSManagedObjectContext from AppDelegate
    class var context : NSManagedObjectContext {
        return self.stack.context
    }
    
    /// Describes a photo entity used for caching
    class private var photoEntity : NSEntityDescription {
        var entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.context)
        return entity!
    }
    
    /// Underlying NSURLSession
    class private var session : NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    static private var task : NSURLSessionTask = {
        return NSURLSessionDataTask()
        }()
    
    /// Remove everything from cache asyncronusly
    public class func discardCacheAsync() {
        var fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.includesPropertyValues = false
        
        var asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            results in
            if let cachedPhotos = results.finalResult as? [Photo]{
                for photo in cachedPhotos {
                    self.context.deleteObject(photo)
                }
            }
        }
        var error : NSError?
        self.context.executeRequest(asyncFetchRequest, error: &error)
    }
    
    /// Remove everything from cache syncronusly
    public class func discardCacheSync() {
        var fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.includesPropertyValues = false
        
        var error : NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as? [Photo]
        
        if let results = fetchedResults {
            for photo in results {
                context.deleteObject(photo)
            }
        }
    }
    
    /**
    Retrives photo from cache.
    :param: URLString url of the photo
    
    :returns: Photo Returns Photo if it exists in cache or nil if it doesn't
    */
    private class func getImageFromCacheSynchronusly(URLString URL : String) -> Photo? {
        var fetchRequest = NSFetchRequest(entityName: "Photo")
        var searchPredicate = NSPredicate(format: "(url = %@)", URL)
        fetchRequest.predicate = searchPredicate
        
        var error : NSError?
        let results = self.context.executeFetchRequest(fetchRequest, error: &error)
        
        if let fetchedPhoto = results {
            if fetchedPhoto.count > 0 {
                let photo = fetchedPhoto[0] as! Photo
                return photo
            } else {
                return nil
            }
        }
        return nil
    }
    
    private class func getImageFromCache(URLString URL : String, completion:(success : Bool, photo: Photo?) -> ()) {
        var fetchRequest = NSFetchRequest(entityName: "Photo")
        var searchPredicate = NSPredicate(format: "(url = %@)", URL)
        fetchRequest.predicate = searchPredicate
        
        var error : NSError?
        
        var asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            results in
            
            if let cachedPhotos = results.finalResult as? [Photo]{
                completion(success: true, photo: cachedPhotos.first)
                return
            } else {
                completion(success: false, photo: nil)
            }
        }
        
        self.context.executeRequest(asyncFetchRequest, error: &error)
    }
    
    /**
    Saves image to the cache, use only when you
    have Photo instance set to be inserted into main context
    
    :param: photo Photo NSManagedObject subclass
    
    :returns: PhotoState State of the inserted photo
    */
    private class func saveImageToCache(photo: Photo) -> PhotoState {
        switch photo.state {
        case PhotoState.Cached.rawValue:
            println("there is photo in the cache saveImageToCache")
            return .Cached
        default:
            photo.state = PhotoState.Cached.rawValue
            break
        }
        
        var error : NSError?
        //        context.save(&error)
        println(error)
        if error != nil { return .Failed }
        println("photo is cached")
        return .Cached
    }
    
    /// Return number of the photos stored in the cache
    public class var numberOfImagesInCache : Int {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.resultType = .CountResultType
        fetchRequest.includesPropertyValues = false
        var error : NSError?
        let results = context.executeFetchRequest(fetchRequest, error: &error) as? [NSNumber]
        
        if error != nil { return 0 }
        
        if let countArray = results {
            let count = countArray[0].integerValue
            return count
        }
        
        return 0
    }
    
    /**
    Use this function to retrive photo using it's URL. If image exists in the cache it will
    be returned using completion block or it will be downloaded and returned through completion
    block and saved to cache.
    
    :param: URLString url of the photo you want to retrieve
    :param: completion completion block that returns success and image
    */
    public class func fetch(URLString URL : String, completion:(success : Bool, image : UIImage?) -> ()) {
        self.getImageFromCache(URLString: URL) {
            success, cachedPhoto in
            if success {
                if let photo = cachedPhoto {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(success : true, image: UIImage(data: photo.image!))
                    })
                } else {
                    
                    let request = NSURLRequest(URL: NSURL(string: URL)!)
                    
                    self.task = self.session.dataTaskWithRequest(request) {
                        data, response, error in
                        println("starting request")
                        if error != nil {
                            completion(success: false, image: nil)
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                completion(success: true, image: UIImage(data: data))
                            })
                            var newPhoto = Photo(entity: self.photoEntity, insertIntoManagedObjectContext: self.context)
                            newPhoto.url = URL
                            newPhoto.state = PhotoState.Downloaded.rawValue
                            newPhoto.image = data
                            
                            self.saveImageToCache(newPhoto)
                            self.stack.saveCache()
                        }
                    }
                    self.task.resume()
                }
            }
        }
    }
    
    public class func saveCache() {
        println("saving cache")
        self.stack.saveCache()
    }
}

public extension UIImageView {
    public func setImageFromPhotoStream(URLString URL : String, placeholderImage placeholder : UIImage, animated : Bool = true) {
//        self.image = placeholder
//        
//        if animated { self.alpha = 0 }
//        PhotoStream.fetch(URLString: URL) {
//            success, photo in
//            if success {
//                if animated {
//                    UIView.animateWithDuration(0.4) {
//                        animations in
//                        self.image = photo
//                        self.alpha = 1
//                    }
//                } else {
//                    self.image = photo
//                }
//            }
//        }
    }
}
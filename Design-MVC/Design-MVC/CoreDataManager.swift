//
//  CoreDataManager.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/12/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    // MARK: - Core Data stack
    
    // dispatch queues
    static let convertQueue = DispatchQueue(label: "convertQueue", qos: .utility)
    static let saveQueue =   DispatchQueue(label: "saveQueue", qos: .utility)
    
    static func saveUser(_ userData: UserData) throws -> User {
        let user = User(context:  persistentContainer.viewContext)
        let allUsersCountFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let count = try self.persistentContainer.viewContext.count(for: allUsersCountFetchRequest)
        user.id       = count + 1 as NSNumber
        user.name     = userData.name
        user.email    = userData.email
        user.password = userData.password
        return user
    }
    
    static func prepareImageForSaving(image: UIImage) {
        
        // use date as unique id
        let date : Double = Date().timeIntervalSince1970
        
        // dispatch with gcd.
        
        convertQueue.async() {
            
            // create NSData from UIImage
            guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                // handle failed conversion
                print("jpg error")
                return
            }
            
            // scale image, I chose the size of the VC because it is easy
            let thumbnail = image.scale(toSize: CGSize( width: 50, height: 50))
            
            guard let thumbnailData  = UIImageJPEGRepresentation(thumbnail, 0.7) else {
                // handle failed conversion
                print("jpg error")
                return
            }
            
            // send to save function
            self.saveImage(with: imageData as NSData, thumbnailData: thumbnailData as NSData, date: date)
            
        }
    }
    
    private static func saveImage(with imageData: NSData, thumbnailData: NSData, date: Double) {
        saveQueue.async(flags: .barrier) {
            // create new objects in moc
//            guard let moc = self.persistentContainer.viewContext else {
//                return
//            }
            let moc = persistentContainer.viewContext
            
            guard let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: moc) as? Photo,
                let thumbnail = NSEntityDescription.insertNewObject(forEntityName: "Thumbnail", into: moc) as? Thumbnail else {
                // handle failed new object in moc
                print("moc error")
                return
            }
            
            //set image data of fullres
            photo.rawData = imageData
            
            //set image data of thumbnail
            thumbnail.rawData = thumbnailData
            thumbnail.id = date as NSNumber
            thumbnail.fullImage = photo
            
            // save the new objects
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            // clear the moc
            moc.refreshAllObjects()
        }
    }

    
    static let persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


extension CGSize {
    
    func resizeFill(toSize: CGSize) -> CGSize {
        
        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))
        
    }
}

extension UIImage {
    
    func scale(toSize newSize:CGSize) -> UIImage {
        
        // make sure the new size has the correct aspect ratio
        let aspectFill = self.size.resizeFill(toSize: newSize)
        
        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: aspectFill.width, height: aspectFill.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

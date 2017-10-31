//
//  Video+CoreDataClass.swift
//  VideoClient
//
//  Created by knax on 9/11/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import Foundation
import CoreData



public class UserVideo: NSManagedObject {
    convenience init(userVideoThumbnail: NSData, userVideoURL: String ,context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entity(forEntityName: "UserVideo", in: context){
            
        self.init(entity: ent, insertInto: context)
        self.userVideoURL = userVideoURL
        self.creationDate = Date() 
        self.videoThumbnail = NSData()
        self.userName = "Guest"
        }
        else{
            fatalError("cannot find entity name")
            
        }
            
    }
    var humanReadableAge: String {
        get {
            let fmt = DateFormatter()
            fmt.timeStyle = .none
            fmt.dateStyle = .short
            fmt.doesRelativeDateFormatting = true
            fmt.locale = Locale.current
            return fmt.string(from: creationDate! as Date)
        }
    }
}


//
//  UserVideo+CoreDataProperties.swift
//  VideoClient
//
//  Created by knax on 9/22/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import Foundation
import CoreData


extension UserVideo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserVideo> {
        return NSFetchRequest<UserVideo>(entityName: "UserVideo")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var userName: String?
    @NSManaged public var userVideoURL: String?
    @NSManaged public var videoThumbnail: NSData?
    @NSManaged public var video: NSData?

}

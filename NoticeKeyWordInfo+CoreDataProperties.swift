//
//  NoticeKeyWordInfo+CoreDataProperties.swift
//  
//
//  Created by JOOMINKYUNG on 8/24/24.
//
//

import Foundation
import CoreData


extension NoticeKeyWordInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoticeKeyWordInfo> {
        return NSFetchRequest<NoticeKeyWordInfo>(entityName: "NoticeKeyWordInfo")
    }

    @NSManaged public var name: String?

}

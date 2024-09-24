//
//  NoticeKeyword+CoreDataProperties.swift
//  
//
//  Created by JOOMINKYUNG on 9/24/24.
//
//

import Foundation
import CoreData


extension NoticeKeyword {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoticeKeyword> {
        return NSFetchRequest<NoticeKeyword>(entityName: "NoticeKeyword")
    }

    @NSManaged public var name: String?

}

//
//  NoticeKeywordInformation+CoreDataProperties.swift
//  
//
//  Created by JOOMINKYUNG on 9/24/24.
//
//

import Foundation
import CoreData


extension NoticeKeywordInformation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoticeKeywordInformation> {
        return NSFetchRequest<NoticeKeywordInformation>(entityName: "NoticeKeywordInformation")
    }

    @NSManaged public var name: String?

}

//
//  RecentSearchedWordInfo+CoreDataProperties.swift
//  
//
//  Created by JOOMINKYUNG on 9/2/24.
//
//

import Foundation
import CoreData


extension RecentSearchedWordInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentSearchedWordInfo> {
        return NSFetchRequest<RecentSearchedWordInfo>(entityName: "RecentSearchedWordInfo")
    }

    @NSManaged public var name: String?
    @NSManaged public var searchedDate: Date?

}

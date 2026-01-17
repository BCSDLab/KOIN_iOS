//
//  RecentSearchedLostItem+CoreDataProperties.swift
//  
//
//  Created by 홍기정 on 1/18/26.
//
//

public import Foundation
public import CoreData


public typealias RecentSearchedLostItemCoreDataPropertiesSet = NSSet

extension RecentSearchedLostItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentSearchedLostItem> {
        return NSFetchRequest<RecentSearchedLostItem>(entityName: "RecentSearchedLostItem")
    }

    @NSManaged public var keyword: String?
    @NSManaged public var date: Date?

}

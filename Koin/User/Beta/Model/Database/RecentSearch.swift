//
//  RecentSearch.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/28.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import CoreData

// ❇️ BlogIdea code generation is turned OFF in the xcdatamodeld file
public class RecentSearch: NSManagedObject, Identifiable {
    @NSManaged public var query: String?
    @NSManaged public var created_at: Date?
}


// MARK: 중복 제거
extension RecentSearch {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func allRecentFetchRequest() -> NSFetchRequest<RecentSearch> {
        let request: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest() as! NSFetchRequest<RecentSearch>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        return request
    }
}

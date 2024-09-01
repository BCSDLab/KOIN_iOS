//
//  ManageRecentSearchedWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/2/24.
//

import Combine
import Foundation

protocol ManageRecentSearchedWordUseCase {
    func changeWord(name: String, date: Date, actionType: Int)
    func fetch() -> [RecentSearchedWordInfo]
}

final class DefaultManageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase {
    func changeWord(name: String, date: Date, actionType: Int) {
        if actionType == 0 {
            let word = RecentSearchedWordInfo(context: CoreDataManager.shared.context)
            word.name = name
            word.searchedDate = date
            
            CoreDataManager.shared.insert(insertedObject: word)
        }
        else {
            let predicate = NSPredicate(format: "name == %@ AND searchedDate == %@", name, date as NSDate)
            
            if let existingKeyWords = CoreDataManager.shared.fetchEntities(objectType: RecentSearchedWordInfo.self, predicate: predicate) {
                for deletedKeyWord in existingKeyWords {
                    CoreDataManager.shared.delete(deletedObject: deletedKeyWord)
                }
            }
        }
    }
    
    func fetch() -> [RecentSearchedWordInfo] {
        let data = CoreDataManager.shared.fetchEntities(objectType: RecentSearchedWordInfo.self)
        if let data = data {
            return data.sorted(by: { $0.searchedDate ?? Date() > $1.searchedDate ?? Date()})
        }
        else {
            return []
        }
    }
}

//
//  ManageRecentSearchedUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/2/24.
//

import Foundation

protocol ManageRecentSearchedUseCase {
    func insert(name: String, date: Date)
    func delete(name: String, date: Date)
    func fetch() -> 
}

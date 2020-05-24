//
//  CommonCommunityDetailViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/14.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

protocol CommonCommunityDetailViewModel {
    associatedtype T: CommonArticle
    associatedtype C: CommonComment
    
    var communityFetcher: CommunityFetchable { get set }
    
    var disposables: Set<AnyCancellable> { get set }
    var article: Int { get set }
    
    var shouldDismissView: Bool { get set }
    
    func dateToString(string_date: String) -> String
    
    var id: Int { get set }
    
    var title: String { get set }
    
    var commentCount: Int { get set }
    
    var hit: Int { get set }
    
    var nickname: String { get set }
    
    var createdAt: String { get set }
    
    var content: String { get set }
    
    var comments: [C] { get set }
    
    //var html: HTMLView { get set }
    
    
    func declarationArticle(type: String)
    
    func grantCheck()
    
    func deleteCommunity()
    
}

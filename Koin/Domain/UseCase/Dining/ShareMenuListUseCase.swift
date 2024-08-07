//
//  ShareMenuListUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/20/24.
//

import Combine
import Foundation

protocol ShareMenuListUseCase {
    func execute(shareModel: ShareDiningMenu)
}

final class DefaultShareMenuListUseCase: ShareMenuListUseCase {
    
    private let diningRepository: DiningRepository
    
    init(diningRepository: DiningRepository) {
        self.diningRepository = diningRepository
    }
    
    func execute(shareModel: ShareDiningMenu) {
        diningRepository.shareMenuList(shareModel: shareModel)
    }
    
}

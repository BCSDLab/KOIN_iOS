//
//  RecruitNotificationListRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import Foundation

struct RecruitNotificationListRequestDto: Encodable {
    let page: Int
    let limit: Int
}

extension RecruitNotificationListRequestDto {
    init(page: Int) {
        self.page = page
        self.limit = 50
    }
}

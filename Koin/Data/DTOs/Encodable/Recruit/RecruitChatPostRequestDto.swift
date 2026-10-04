//
//  RecruitChatPostRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitChatPostRequestDto: Encodable {
    let content: String
    let isImage: Bool

    enum CodingKeys: String, CodingKey {
        case content
        case isImage = "is_image"
    }
}

extension RecruitChatPostRequestDto {
    init(from request: RecruitChatPostRequest) {
        self.content = request.content
        self.isImage = request.isImage
    }
}

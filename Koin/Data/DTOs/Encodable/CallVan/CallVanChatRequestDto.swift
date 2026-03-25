//
//  CallVanChatRequestDto.swift
//  koin
//
//  Created by 홍기정 on 3/17/26.
//

import Foundation

struct CallVanChatRequestDto: Codable {
    let isImage: Bool
    let content: String

    enum CodingKeys: String, CodingKey {
        case isImage = "is_image"
        case content
    }
}

extension CallVanChatRequestDto {
    init(from model: CallVanChatRequest) {
        self.isImage = model.isImage
        self.content = model.content
    }
}

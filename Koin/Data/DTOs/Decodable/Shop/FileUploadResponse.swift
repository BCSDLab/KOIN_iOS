//
//  FileUploadResponse.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Foundation

struct FileUploadResponse: Decodable {
    let fileUrls: [String]
    enum CodingKeys: String, CodingKey {
        case fileUrls = "file_urls"
    }
}

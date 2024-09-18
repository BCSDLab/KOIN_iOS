//
//  NoticeDataInfo.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/20/24.
//

import Foundation

struct NoticeDataInfo {
    let title: String
    let boardId: Int
    let content: String
    let author: String
    let hit: Int
    let prevId: Int?
    let nextId: Int?
    let attachments: [NoticeAttachmentDTO]
    let registeredAt: String
}

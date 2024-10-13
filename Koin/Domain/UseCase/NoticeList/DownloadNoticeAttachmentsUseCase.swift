//
//  DownloadNoticeAttachmentsUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/18/24.
//

import Combine
import Foundation

protocol DownloadNoticeAttachmentsUseCase {
    func execute(downloadUrl: String, fileName: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDownloadNoticeAttachmentsUseCase: DownloadNoticeAttachmentsUseCase {
    private let noticeRepository: NoticeListRepository
    
    init(noticeRepository: NoticeListRepository) {
        self.noticeRepository = noticeRepository
    }
    
    func execute(downloadUrl: String, fileName: String) -> AnyPublisher<Void, ErrorResponse> {
        return noticeRepository.downloadNoticeAttachment(downloadUrl: downloadUrl, fileName: fileName).eraseToAnyPublisher()
    }
}

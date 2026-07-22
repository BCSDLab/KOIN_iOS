//
//  FetchMainFrameUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import Foundation
import Combine

protocol FetchMainFrameUseCase {
    func execute() -> AnyPublisher<[LectureData], ErrorResponse>
}

final class DefaultFetchMainFrameUseCase: FetchMainFrameUseCase {
    
    private let fetchFramesUseCase: FetchFramesUseCase
    private let fetchFrameUseCase: FetchFrameUseCase
    private let fetchLectureUseCase: FetchLectureUseCase
    
    init(
        fetchFramesUseCase: FetchFramesUseCase,
        fetchFrameUseCase: FetchFrameUseCase,
        fetchLectureUseCase: FetchLectureUseCase
    ) {
        self.fetchFramesUseCase = fetchFramesUseCase
        self.fetchFrameUseCase = fetchFrameUseCase
        self.fetchLectureUseCase = fetchLectureUseCase
    }
    
    func execute() -> AnyPublisher<[LectureData], ErrorResponse> {
        fetchFramesUseCase.execute()
            .compactMap { $0.first?.semester }
            .flatMap { [fetchFrameUseCase = fetchFrameUseCase] semester in
                fetchFrameUseCase.execute(semester: semester)
            }
            .compactMap { $0.first(where: \.isMain) }
            .flatMap { [fetchLectureUseCase = fetchLectureUseCase] mainFrame in
                fetchLectureUseCase.execute(frameId: mainFrame.id)
            }
            .eraseToAnyPublisher()
    }
}

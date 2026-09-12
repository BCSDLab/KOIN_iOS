//
//  RecruitDataViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/12/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecruitDataViewModel: SwiftUIViewModelProtocol {
    
    enum Input {
        case load
        case delete
        case didShowToast
    }
    
    // MARK: - State
    private(set) var data: RecruitData?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var didDelete = false
    
    // MARK: - Properties
    private let recruitId: Int
    private let fetchRecruitDataUseCase: FetchRecruitDataUseCase
    private let deleteRecruitDataUseCase: DeleteRecruitDataUseCase
    
    // MARK: - Initializer
    init(
        fetchRecruitDataUseCase: FetchRecruitDataUseCase,
        deleteRecruitDataUseCase: DeleteRecruitDataUseCase,
        recruitId: Int
    ) {
        self.fetchRecruitDataUseCase = fetchRecruitDataUseCase
        self.deleteRecruitDataUseCase = deleteRecruitDataUseCase
        self.recruitId = recruitId
    }
    
    func execute(_ input: Input) {
        switch input {
        case .load:
            load()
        case .delete:
            delete()
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitDataViewModel {
    private func load() {
        guard !isLoading else { return }
        
        Task {
            do {
                isLoading = true
                defer {
                    isLoading = false
                }
                let data = try await fetchRecruitDataUseCase.execute(id: recruitId)
                self.data = data
            } catch {
                if let error = error as? ErrorResponse {
                    errorMessage = error.message
                }
            }
        }
    }
    
    private func delete() {
        guard let data else {
            return
        }
        Task {
            do {
                isLoading = true
                defer {
                    isLoading = false
                }
                
                let result = try await deleteRecruitDataUseCase.execute(id: data.id)
                guard result == true else {
                    errorMessage = "오류가 발생했습니다."
                    return
                }
                self.didDelete = true
            } catch {
                if let error = error as? ErrorResponse {
                    errorMessage = error.message
                }
                self.didDelete = false
            }
        }
    }
}

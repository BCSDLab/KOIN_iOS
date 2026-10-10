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
        case applicationSubmitted
        case didShowToast
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - State
    private(set) var data: RecruitData?
    private(set) var errorMessage: String?
    private(set) var didDelete = false
    
    var isLoading: Bool {
        if fetchTask == nil && deleteTask == nil {
            return false
        }
        return true
    }
    
    // MARK: - Properties
    private let recruitId: Int
    private let fetchRecruitDataUseCase: FetchRecruitDataUseCase
    private let deleteRecruitDataUseCase: DeleteRecruitDataUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var fetchTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?
    
    // MARK: - Initializer
    init(
        fetchRecruitDataUseCase: FetchRecruitDataUseCase,
        deleteRecruitDataUseCase: DeleteRecruitDataUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        recruitId: Int
    ) {
        self.fetchRecruitDataUseCase = fetchRecruitDataUseCase
        self.deleteRecruitDataUseCase = deleteRecruitDataUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.recruitId = recruitId
    }
    
    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .load:
            load()
        case .delete:
            delete()
        case .applicationSubmitted:
            applicationSubmitted()
        case .didShowToast:
            errorMessage = nil
        case let .logEvent(label, category, value):
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
}

extension RecruitDataViewModel {
    private func load() {
        guard !isLoading else { return }
        
        fetchTask = Task {
            defer {
                fetchTask = nil
            }
            do {
                let data = try await fetchRecruitDataUseCase.execute(id: recruitId)
                self.data = data
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
    
    private func delete() {
        guard let data, !isLoading else {
            return
        }
        deleteTask = Task {
            defer {
                deleteTask = nil
            }
            do {
                let result = try await deleteRecruitDataUseCase.execute(id: data.id)
                guard result == true else {
                    errorMessage = "오류가 발생했습니다."
                    return
                }
                self.didDelete = true
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
                self.didDelete = false
            }
        }
    }
}

extension RecruitDataViewModel {
    private func applicationSubmitted() {
        data?.markAsAlreadyApplied()
        load()
    }
}

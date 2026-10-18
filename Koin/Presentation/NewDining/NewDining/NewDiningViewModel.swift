//
//  NewDiningViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import Foundation
import Combine

@Observable
final class NewDiningViewModel: SwiftUIViewModelProtocol {
    enum Input {
        case onFirstAppear
        case changeSelectedDate(Date)
        case changeSelectedDiningType(DiningType)
        case refresh
        case didShowToast
        case didTapCloseShareTooltip
        case didTapShare(DiningItem)
        case didTapSoldOutSwitch(Bool)
        case didTapImageUploadSwitch(Bool)
    }
    
    // MARK: - Proeprteis
    private let dateProvider: DateProvider
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let shareMenuListUseCase: ShareMenuListUseCase
    private let fetchDiningNotiUseCase: FetchDiningNotiUseCase
    private let changeNotiUseCase: ChangeNotiUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    private var fetchDiningListTask: Task<Void, Never>?
    
    // MARK: - State
    private(set) var dates: [Date] = []
    private(set) var selectedDate: Date = Date()
    private(set) var selectedDiningType: DiningType = .breakfast
    private(set) var diningLists: [DiningList] = []
    private(set) var toastMessage: String?
    private(set) var shouldShowShareTooltip = !UserDefaults.standard.bool(forKey: "hasShownDiningShareTooltip")
    private(set) var shouldPresentNotiBottomSheet = !UserDefaults.standard.bool(forKey: "hasShownBottomSheet") && UserDataManager.shared.isLoggedIn
    private(set) var diningNoti: DiningNoti?
    
    // MARK: - Initializer
    init(
        dateProvider: DateProvider,
        fetchDiningListUseCase: FetchDiningListUseCase,
        shareMenuListUseCase: ShareMenuListUseCase,
        fetchDiningNotiUseCase: FetchDiningNotiUseCase,
        changeNotiUseCase: ChangeNotiUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        selectedDate: Date? = nil,
        selectedDiningType: DiningType? = nil
    ) {
        self.dateProvider = dateProvider
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.shareMenuListUseCase = shareMenuListUseCase
        self.fetchDiningNotiUseCase = fetchDiningNotiUseCase
        self.changeNotiUseCase = changeNotiUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        initializeDates()
        fetchDiningDate(selectedDate: selectedDate, selectedDiningType: selectedDiningType)
        
        #if DEBUG
        shouldShowShareTooltip = true
        #endif
    }
    
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchDiningList()
            fetchNotiListIfNeeded()
        case .refresh:
            fetchDiningList()
        case let .changeSelectedDate(date):
            changeSelectedDate(date)
        case let .changeSelectedDiningType(type):
            changeSelectedDiningType(type)
        case .didShowToast:
            toastMessage = nil
        case .didTapCloseShareTooltip:
            hideShareTooltip()
        case let .didTapShare(selecteItem):
            shareMenuList(selectedItem: selecteItem)
        case let .didTapSoldOutSwitch(isOn):
            changeNoti(isOn: isOn, type: .diningSoldOut)
        case let .didTapImageUploadSwitch(isOn):
            changeNoti(isOn: isOn, type: .diningImageUpload)
        }
    }
}

extension NewDiningViewModel {
    private func initializeDates() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        dates = (-3...3).compactMap {
            calendar.date(byAdding: .day, value: $0, to: today)
        }
    }
    private func fetchDiningDate(selectedDate: Date?, selectedDiningType: DiningType?) {
        if let selectedDate,
           let selectedDiningType,
           dates.contains(selectedDate) {
            self.selectedDate = selectedDate
            self.selectedDiningType = selectedDiningType
        } else {
            let currentDiningTime = dateProvider.execute(date: Date())
            self.selectedDate = currentDiningTime.date
            self.selectedDiningType = currentDiningTime.diningType
        }
    }
    private func fetchDiningList() {
        fetchDiningListTask?.cancel()
        
        fetchDiningListTask = Task {
            do {
                let result = try await fetchDiningListUseCase.execute(date: selectedDate).firstValue()
                guard !Task.isCancelled else { return }
                diningLists = result
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension NewDiningViewModel {
    private func changeSelectedDate(_ date: Date) {
        if selectedDate != date {
            selectedDate = date
            fetchDiningList()
        }
    }
    
    private func changeSelectedDiningType(_ type: DiningType) {
        if selectedDiningType != type {
            selectedDiningType = type
        }
    }
}

extension NewDiningViewModel {
    private func hideShareTooltip() {
        UserDefaults.standard.set(true, forKey: "hasShownDiningShareTooltip")
        shouldShowShareTooltip = false
    }
}

extension NewDiningViewModel {
    private func shareMenuList(selectedItem: DiningItem) {
        let shareModel = ShareDiningMenu(
            menuList: selectedItem.menu,
            imageUrl: selectedItem.image.imageUrl,
            date: selectedItem.date.formatDateToYYMMDD(),
            type: selectedItem.type,
            place: selectedItem.place
        )
        shareMenuListUseCase.execute(shareModel: shareModel)
    }
}

extension NewDiningViewModel {
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

extension NewDiningViewModel {
    private func fetchNotiListIfNeeded() {
        guard shouldPresentNotiBottomSheet else {
            return
        }
        Task {
            do {
                diningNoti = try await fetchDiningNotiUseCase.execute()
            } catch let error as ErrorResponse where error.code == ErrorResponse.typeCastingError.code {
                return
            } catch let error as ErrorResponse where error.statusCode == 401 {
                return
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension NewDiningViewModel {
    private func changeNoti(isOn: Bool, type: SubscribeType) {
        Task {
            do {
                try await changeNotiUseCase.execute(
                    method: isOn ? .post : .delete,
                    type: type
                ).firstValue()
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

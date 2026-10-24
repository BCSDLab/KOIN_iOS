//
//  DiningViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import Foundation
import Combine

@Observable
final class DiningViewModel: SwiftUIViewModelProtocol {
    enum Input {
        case onFirstAppear
        case changeSelectedDate(Date)
        case changeSelectedDiningType(DiningType)
        case refresh
        case didShowToast
        case didTapCloseShareTooltip
        case didTapCloseReportTooltip
        case didTapReport(
            selectedItem: DiningItem,
            imageData: Data
        )
        case didTapShare(DiningItem)
        case didTapSoldOutSwitch(Bool)
        case didTapImageUploadSwitch(Bool)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Proeprteis
    private let dateProvider: DateProvider
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let shareMenuListUseCase: ShareMenuListUseCase
    private let fetchDiningNotiUseCase: FetchDiningNotiUseCase
    private let changeNotiUseCase: ChangeNotiUseCase
    private let fetchCurrentDiningItemsUseCase: FetchCurrentDiningItemsUseCase
    private let reportSoldoutDiningUseCase: ReportSoldoutDiningUseCase
    private let uploadFileUseCase: UploadFileUseCase
    private let assignAbTestUseCase: AssignAbTestUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    private var fetchDiningListTask: Task<Void, Never>?
    
    // MARK: - State
    private(set) var dates: [Date] = []
    private(set) var selectedDate: Date = Date()
    private(set) var selectedDiningType: DiningType = .breakfast
    private(set) var diningLists: [DiningList] = []
    private(set) var currentDiningItems: [DiningItem] = []
    private(set) var toastMessage: String?
    private(set) var didFinishReporting: Int = 0
    private(set) var shouldShowShareTooltip = !UserDefaults.standard.bool(forKey: "hasShownDiningShareTooltip")
    private(set) var shouldShowReportTooltip = !UserDefaults.standard.bool(forKey: "shouldHideReportTooltip")
    private(set) var shouldPresentNotiBottomSheet = !UserDefaults.standard.bool(forKey: "hasShownBottomSheet") && UserDataManager.shared.isLoggedIn
    private(set) var diningNoti: DiningNoti?
    
    // MARK: - AbTest
    private(set) var reportAbTest: DiningReportAbTest?
    
    // MARK: - Initializer
    init(
        dateProvider: DateProvider,
        fetchDiningListUseCase: FetchDiningListUseCase,
        shareMenuListUseCase: ShareMenuListUseCase,
        fetchDiningNotiUseCase: FetchDiningNotiUseCase,
        changeNotiUseCase: ChangeNotiUseCase,
        fetchCurrentDiningItemsUseCase: FetchCurrentDiningItemsUseCase,
        reportSoldoutDiningUseCase: ReportSoldoutDiningUseCase,
        uploadFileUseCase: UploadFileUseCase,
        assignAbTestUseCase: AssignAbTestUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        selectedDate: Date? = nil,
        selectedDiningType: DiningType? = nil
    ) {
        self.dateProvider = dateProvider
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.shareMenuListUseCase = shareMenuListUseCase
        self.fetchDiningNotiUseCase = fetchDiningNotiUseCase
        self.changeNotiUseCase = changeNotiUseCase
        self.fetchCurrentDiningItemsUseCase = fetchCurrentDiningItemsUseCase
        self.reportSoldoutDiningUseCase = reportSoldoutDiningUseCase
        self.uploadFileUseCase = uploadFileUseCase
        self.assignAbTestUseCase = assignAbTestUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        initializeDates()
        fetchDiningDate(selectedDate: selectedDate, selectedDiningType: selectedDiningType)
        
        #if DEBUG
        shouldShowShareTooltip = true
        shouldShowReportTooltip = true
        #endif
    }
    
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchDiningList()
            fetchCurrnetDiningItems()
            assignReportABTest()
            fetchNotiListIfNeeded()
        case .refresh:
            fetchDiningList()
            fetchCurrnetDiningItems()
        case let .changeSelectedDate(date):
            changeSelectedDate(date)
        case let .changeSelectedDiningType(type):
            changeSelectedDiningType(type)
        case .didShowToast:
            toastMessage = nil
        case .didTapCloseShareTooltip:
            hideShareTooltip()
        case .didTapCloseReportTooltip:
            hideReportTooltip()
        case let .didTapReport(selectedItem, imageData):
            postReport(selectedItem, imageData)
        case let .didTapShare(selecteItem):
            shareMenuList(selectedItem: selecteItem)
        case let .didTapSoldOutSwitch(isOn):
            changeNoti(isOn: isOn, type: .diningSoldOut)
        case let .didTapImageUploadSwitch(isOn):
            changeNoti(isOn: isOn, type: .diningImageUpload)
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
        }
    }
}

extension DiningViewModel {
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
    private func fetchCurrnetDiningItems() {
        Task {
            do {
                currentDiningItems = try await fetchCurrentDiningItemsUseCase.execute()
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension DiningViewModel {
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

extension DiningViewModel {
    private func assignReportABTest() {
        Task {
            do {
                let request = AssignAbTestRequest(title: "icon_location")
                let result = try await assignAbTestUseCase.execute(requestModel: request).firstValue()
                reportAbTest = DiningReportAbTest(from: result.variableName.rawValue)
                if let reportAbTest {
                    makeLogAnalyticsEvent(label: EventParameter.EventLabel.Campus.Dining.cafeteriaDiningAbtestExposure, category: .exposure, value: reportAbTest.logValue)
                }
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
    private func hideShareTooltip() {
        UserDefaults.standard.set(true, forKey: "hasShownDiningShareTooltip")
        shouldShowShareTooltip = false
    }
    
    private func hideReportTooltip() {
        UserDefaults.standard.set(true, forKey: "shouldHideReportTooltip")
        shouldShowReportTooltip = false
    }
}

extension DiningViewModel {
    private func postReport(
        _ selectedItem: DiningItem,
        _ imageData: Data
    ) {
        Task {
            do {
                defer {
                    didFinishReporting += 1
                }
                guard let imageUrl = try await uploadFileUseCase.execute(
                    files: [imageData],
                    domain: .coop
                )
                .firstValue()
                .fileUrls
                .first else {
                    throw ErrorResponse.imageUploadError
                }
                try await reportSoldoutDiningUseCase.execute(
                    diningId: selectedItem.id,
                    imageUrl: imageUrl
                )
                toastMessage = "\(selectedItem.place.name) 품절을 제보했습니다."
                makeReportLogEvent(category: .submit, selectedItem: selectedItem)
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
                makeReportLogEvent(category: .fail, selectedItem: selectedItem)
            }
        }
    }
}

extension DiningViewModel {
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

extension DiningViewModel {
    private func makeReportLogEvent(
        category: EventParameter.EventCategory,
        selectedItem: DiningItem?
    ) {
        guard let reportAbTestName = reportAbTest?.logValue else {
            return
        }
        makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.Dining.cafeteriaDiningSoldoutSubmit,
            category: category,
            value: "\(reportAbTestName)_\(selectedItem?.place.name ?? "None")"
        )
    }
    
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

extension DiningViewModel {
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

extension DiningViewModel {
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

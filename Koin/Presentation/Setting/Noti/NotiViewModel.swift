//
//  NotiViewModel.swift
//  koin
//
//  Created by 김나훈 on 4/18/24.
//


import Combine

final class NotiViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case getNotiAgreementList
        case switchChanged(SubscribeType, Bool)
        case switchDetailChanged(DetailSubscribeType, Bool)
        case logEvent(EventLabelType, Any)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateSwitch(NotiAgreementDto)
        case changeButtonEnableStatus(Bool)
        case requestLogInAgain
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let changeNotiUseCase: ChangeNotiUseCase
    private let changeNotiDetailUseCase: ChangeNotiDetailUseCase
    private let fetchNotiListUseCase: FetchNotiListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    // MARK: - Initialization
    
    init(changeNotiUseCase: ChangeNotiUseCase, changeNotiDetailUseCase: ChangeNotiDetailUseCase, fetchNotiListUseCase: FetchNotiListUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.changeNotiUseCase = changeNotiUseCase
        self.changeNotiDetailUseCase = changeNotiDetailUseCase
        self.fetchNotiListUseCase = fetchNotiListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getNotiAgreementList:
                self?.getNotiAgreementList()
            case let .switchChanged(type, isOn):
                self?.subscribeNoti(type: type, isOn: isOn)
            case let .switchDetailChanged(detailType,isOn):
                self?.subscribeDetailNoti(detailType: detailType, isOn: isOn)
            case let .logEvent(label, value):
                self?.makeLogAnalyticsEvent(label: label, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension NotiViewModel {
    
    private func subscribeNoti(type: SubscribeType, isOn: Bool) {
        
        changeNotiUseCase.execute(method: isOn ? .post : .delete, type: type).sink { [weak self] completion in
            if case .failure = completion {
                self?.outputSubject.send(.requestLogInAgain)
            }
        } receiveValue: { [weak self] response in
            if type == .diningSoldOut {
                self?.outputSubject.send(.changeButtonEnableStatus(isOn))
                self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Dining.notificationConfigSoldOutToggle, value: isOn ? "켜짐" : "꺼짐")
            }
            else if type == .diningImageUpload {
                self?.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Dining.notificationConfigNotificationConfigPhotoUploadToggle, value: isOn ? "켜짐" : "꺼짐")
            }
            
        }.store(in: &subscriptions)

    }
    
    private func subscribeDetailNoti(detailType: DetailSubscribeType, isOn: Bool) {
        changeNotiDetailUseCase.execute(method: isOn ? .post : .delete, detailType: detailType).sink { [weak self] completion in
            if case .failure = completion {
                self?.outputSubject.send(.requestLogInAgain)
            }
        } receiveValue: { [weak self] response in
            self?.makeLogByDetailSubsciption(type: detailType, isOn: isOn)
        }.store(in: &subscriptions)

    }
    
    private func getNotiAgreementList() {
        fetchNotiListUseCase.execute().sink { [weak self] completion in
            if case .failure = completion {
                self?.outputSubject.send(.requestLogInAgain)
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateSwitch(response))
        }.store(in: &subscriptions)

    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, value: value)
    }

    private func makeLogByDetailSubsciption(type: DetailSubscribeType, isOn: Bool) {
        let mealTime: String
        switch type {
        case .breakfast:
            mealTime = "아침"
        case .lunch:
            mealTime = "점심"
        case .dinner:
            mealTime = "저녁"
        }
        makeLogAnalyticsEvent(label: EventParameter.EventLabel.Dining.notificationConfigSoldOutMealToggle, value: "\(mealTime)_\(isOn ? "켜짐" : "꺼짐")")
    }
}

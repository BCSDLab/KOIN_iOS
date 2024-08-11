//
//  DiningViewModel.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine
import Foundation

final class DiningViewModel: ViewModelProtocol {
    
    enum Input {
        case updateDisplayDateTime(Date?, DiningType?)
        case shareMenuList(ShareDiningMenu)
        case determineInitDate
        case diningLike(Int, Bool)
        case changeNoti(Bool, SubscribeType)
        case fetchNotiList
        case sendDeviceToken
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateDiningList([DiningItem], DiningType)
        case updateDiningLike(Int, Bool)
        case initCalendar(String)
        case showBottomSheet((Bool, Bool))
        case showLoginModal
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let shareMenuListUseCase: ShareMenuListUseCase
    private let diningLikeUseCase: DiningLikeUseCase
    private let changeNotiUseCase: ChangeNotiUseCase
    private let changeNotiDetailUseCase: ChangeNotiDetailUseCase
    private let fetchNotiListUseCase: FetchNotiListUseCase
    private let sendDeviceTokenUseCase: SendDeviceTokenUseCase
    private let dateProvider: DateProvider
    private var subscriptions: Set<AnyCancellable> = []
    private var sharedDiningItem: CurrentDiningTime?
    private var currentDate: CurrentDiningTime = .init(date: Date(), diningType: .breakfast) {
        didSet {
            updateDiningList()
        }
    }
    
    init(fetchDiningListUseCase: FetchDiningListUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, dateProvder: DateProvider, shareMenuListUseCase: ShareMenuListUseCase, diningLikeUseCase: DiningLikeUseCase, changeNotiUseCase: ChangeNotiUseCase, fetchNotiListUsecase: FetchNotiListUseCase, changeNotiDetailUseCase: ChangeNotiDetailUseCase, sendDeviceTokenUseCase: SendDeviceTokenUseCase, sharedDiningItem: CurrentDiningTime? = nil) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.dateProvider = dateProvder
        self.shareMenuListUseCase = shareMenuListUseCase
        self.diningLikeUseCase = diningLikeUseCase
        self.changeNotiUseCase = changeNotiUseCase
        self.fetchNotiListUseCase = fetchNotiListUsecase
        self.changeNotiDetailUseCase = changeNotiDetailUseCase
        self.sendDeviceTokenUseCase = sendDeviceTokenUseCase
        self.sharedDiningItem = sharedDiningItem
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case let .updateDisplayDateTime(date, diningType):
                self.updateDisplayDateTime(date: date, type: diningType)
            case .determineInitDate:
                if let sharedDiningItem {
                    outputSubject.send(.initCalendar(sharedDiningItem.date.dayOfMonth()))
                } else {
                    outputSubject.send(.initCalendar(self.currentDate.date.dayOfMonth()))
                }
                self.currentDate = self.dateProvider.execute(date: Date())
            case let .logEvent(label, category, value):
                self.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case let .shareMenuList(shareModel):
                self.shareMenuList(shareModel: shareModel)
            case let .diningLike(id, isLiked):
                self.diningLike(id, isLiked)
            case let .changeNoti(isOn, subscribeType):
                self.changeNoti(isOn: isOn, type: subscribeType)
            case .fetchNotiList:
                self.fetchNotiList()
            case .sendDeviceToken:
                self.sendDeviceToken()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension DiningViewModel {
    private func sendDeviceToken() {
        sendDeviceTokenUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { response in
            print(response)
        }.store(in: &subscriptions)
        
    }
    private func fetchNotiList() {
        fetchNotiListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            let tuple = self.processSubscribes(response: response)
            self.outputSubject.send(.showBottomSheet(tuple))
        }.store(in: &subscriptions)
    }
    
    private func processSubscribes(response: NotiAgreementDTO) -> (Bool, Bool) {
        var diningSoldOutPermit: Bool = false
        var diningImageUploadPermit: Bool = false
        
        response.subscribes?.forEach { subscribe in
            guard let type = subscribe.type, let isPermit = subscribe.isPermit else { return }
            switch type {
            case .diningSoldOut:
                diningSoldOutPermit = isPermit
            case .diningImageUpload:
                diningImageUploadPermit = isPermit
            default:
                break
            }
        }
        return (diningSoldOutPermit, diningImageUploadPermit)
    }
    
    private func changeNoti(isOn: Bool, type: SubscribeType) {
        changeNotiUseCase.execute(method: isOn ? .post : .delete , type: type).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            if type == .diningSoldOut && isOn {
                DetailSubscribeType.allCases.forEach {
                    self?.changeNotiDetail(isOn: isOn, detailType: $0)
                }
            }
        }.store(in: &subscriptions)
    }
    
    private func changeNotiDetail(isOn: Bool, detailType: DetailSubscribeType) {
        changeNotiDetailUseCase.execute(method: isOn ? .post : .delete , detailType: detailType).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { response in
            print(response)
        }.store(in: &subscriptions)
    }
    
    private func diningLike(_ id: Int, _ isLiked: Bool) {
        diningLikeUseCase.execute(diningId: id, isLiked: isLiked).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showLoginModal)
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateDiningLike(id, !isLiked))
        }.store(in: &subscriptions)
    }
    
    private func shareMenuList(shareModel: ShareDiningMenu) {
        shareMenuListUseCase.execute(shareModel: shareModel)
    }
    
    // TODO: 로직 고치기.. 맘에 들지 않는다...
    private func updateDiningList() {
        let fetchDate: CurrentDiningTime
        if let sharedDiningItem {
            fetchDate = sharedDiningItem
        } else {
            fetchDate = currentDate
        }
        sharedDiningItem = nil
        
        fetchDiningListUseCase.execute(diningInfo: fetchDate).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] list in
            guard let self = self else { return }
            self.outputSubject.send(.updateDiningList(list, currentDate.diningType))
        }.store(in: &subscriptions)
    }
    
    private func updateDisplayDateTime(date: Date?, type: DiningType?) {
        if let date = date {
            currentDate.date = date
        }
        if let type = type {
            currentDate.diningType = type
        }
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


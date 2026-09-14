//
//  CallVanPostViewController.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import Combine
import SnapKit
import Then

protocol CallVanPostViewControllerDelegate: AnyObject {
    func appendPostData(_ postData: CallVanListPost)
}

final class CallVanPostViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CallVanPostViewControllerDelegate?
    private let inputSubject = PassthroughSubject<CallVanPostViewModel.Input, Never>()
    private let viewModel: CallVanPostViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let placeView = CallVanPostPlaceView()
    private let dateView = CallVanPostDateView()
    private let timeView = CallVanPostTimeView()
    private let participantsView = CallVanPostParticipantsView()
    
    private let separatorView = UIView()
    private let descriptionLabel = UILabel()
    private let postButton = UIButton()
    
    private let bottomSheetContentView = CallVanPostPlaceBottomSheetView()
    
    // MARK: - Dropdown
    private lazy var dropdownHost = KoinDropdownHost(scrollView: scrollView)
    private lazy var dateDropdown = dropdownHost.makeDropdown(
        trigger: dateView.dropdownTrigger,
        contentView: dateView.dropdownContentView,
        configuration: .init(topPadding: 12, shadow: .shadow2)
    )
    private lazy var timeDropdown = dropdownHost.makeDropdown(
        trigger: timeView.dropdownTrigger,
        contentView: timeView.dropdownContentView,
        configuration: .init(topPadding: 12, shadow: .shadow2)
    )
    
    // MARK: - Initializer
    init(viewModel: CallVanPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "콜밴팟"
        configureNavigationBar(style: .empty)
        configureView()
        setAddTargets()
        bind()
        dateView.update(Date())
        timeView.update(Date())
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).receive(on: DispatchQueue.main).sink { [weak self] output in
                guard let self else { return }
                switch output {
                case let .enablePostButton(isEnabled):
                    postButton.isEnabled = isEnabled
                    postButton.backgroundColor = isEnabled ? UIColor.appColor(.new500) : UIColor.appColor(.neutral400)
                case let .updateDeparture(placeType, customPlace):
                    placeView.updateDeparture(placeType: placeType, customPlace: customPlace)
                case let .updateArrival(placeType, customPlace):
                    placeView.updateArrival(placeType: placeType, customPlace: customPlace)
                case let .postDataCompleted(postData):
                    postDataCompleted(postData)
                case let .showToast(message):
                    postButton.isUserInteractionEnabled = true
                    showToastMessage(message: message)
                case let .showRestrictedModal(type, until):
                    showRestrictedModal(type, until)
                }
            }.store(in: &subscriptions)
        
        placeView.departureButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.presentDeparturePlaceBottomSheet()
        }.store(in: &subscriptions)
        
        placeView.arrivalButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.presentArrivalPlaceBottomSheet()
        }.store(in: &subscriptions)
        
        placeView.swapButtonTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.swapButtonTapped)
        }.store(in: &subscriptions)
        
        placeView.departureChangedPublisher.sink { [weak self] (departureType, customPlace) in
            self?.inputSubject.send(.updateDeparture(departureType, customPlace))
        }.store(in: &subscriptions)
        
        placeView.arrivalChangedPublisher.sink { [weak self] (departureType, customPlace) in
            self?.inputSubject.send(.updateArrival(departureType, customPlace))
        }.store(in: &subscriptions)
        
        dateView.dateButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
                self?.dateDropdown.toggle()
            }.store(in: &subscriptions)
        
        dateView.dateChangedPublisher.sink { [weak self] date in
            self?.inputSubject.send(.updateDepartureDate(date))
        }.store(in: &subscriptions)
        
        timeView.timeButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
                self?.timeDropdown.toggle()
            }.store(in: &subscriptions)
        
        timeView.timeChangedPublisher.sink { [weak self] time in
            let value = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "a hh:mm"
                return formatter.string(from: time)
            }()
            self?.inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanWriteTime, category: .click, value: value))
            self?.inputSubject.send(.updateDepartureTime(time))
        }.store(in: &subscriptions)
        
        participantsView.participantsChangedPublisher.sink { [weak self] participants in
            self?.inputSubject.send(.updateMaxParticipants(participants))
        }.store(in: &subscriptions)
    }
}

extension CallVanPostViewController: PopLoggable {
    func sendPopLog(category: EventParameter.EventCategory) {
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanWriteBack, category: category, value: ""))
    }
}

extension CallVanPostViewController {
    private func setAddTargets() {
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    @objc private func postButtonTapped() {
        guard !dropdownHost.isPresenting else { return }

        postButton.isUserInteractionEnabled = false
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanWriteDone, category: .click, value: ""))
        inputSubject.send(.postData)
    }
}

extension CallVanPostViewController {
    
    private func showRestrictedModal(_ type: RestrictionType?, _ until: String?) {
        let mainTitle: String
        let subTitle: String
        
        switch type {
        case .temporaryRestriction14Days:
            mainTitle = RestrictionType.temporaryRestriction14Days.rawValue
            subTitle = RestrictionType.temporaryRestriction14Days.getDescription(until: until)
        case .permanentRestriction:
            mainTitle = RestrictionType.permanentRestriction.rawValue
            subTitle = RestrictionType.permanentRestriction.getDescription()
        case nil:
            return
        }
        
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: mainTitle,
                subTitleText: subTitle
            ),
            button: .singleButton(
                title: "닫기"
            )
        ))
        present(modalViewController, animated: true)
    }
    
    private func presentDeparturePlaceBottomSheet() {
        let onApplyButtonTapped: (CallVanPlace, String?)->Void = { [weak self] (place, customPlace) in
            guard let self else { return }
            placeView.updateDeparture(placeType: place, customPlace: customPlace)
            inputSubject.send(.updateDeparture(place, customPlace))
            
            let value = place == .custom ? "\(place.rawValue), \(customPlace ?? "")" : "\(place.rawValue)"
            inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanWriteDeparture, category: .click, value: value))
        }
        bottomSheetContentView.configure(
            title: .departure,
            selectedPlace: viewModel.request.departureType,
            customPlace: viewModel.request.departureCustomName,
            onApplyButtonTapped: onApplyButtonTapped
        )
        presentPlaceBottomSheet()
    }

    private func presentArrivalPlaceBottomSheet() {
        let onApplyButtonTapped: (CallVanPlace, String?)->Void = { [weak self] (place, customPlace) in
            guard let self else { return }
            placeView.updateArrival(placeType: place, customPlace: customPlace)
            inputSubject.send(.updateArrival(place, customPlace))
            
            let value = place == .custom ? "\(place.rawValue), \(customPlace ?? "")" : "\(place.rawValue)"
            inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanWriteArrival, category: .click, value: value))
        }
        bottomSheetContentView.configure(
            title: .arrival,
            selectedPlace: viewModel.request.arrivalType,
            customPlace: viewModel.request.arrivalCustomName,
            onApplyButtonTapped: onApplyButtonTapped
        )
        presentPlaceBottomSheet()
    }

    private func presentPlaceBottomSheet() {
        let bottomSheetViewController = BottomSheetViewControllerB(contentView: bottomSheetContentView)
        bottomSheetContentView.delegate = bottomSheetViewController
        present(bottomSheetViewController, animated: false)
    }
}

extension CallVanPostViewController {
    
    private func postDataCompleted(_ postData: CallVanListPost) {
        delegate?.appendPostData(postData)
        
        if let viewController = navigationController?.viewControllers.first(where: { $0 is CallVanListViewController }) {
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
            let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchCallVanListUseCase = DefaultFetchCallVanListUseCase(repository: callVanRepository)
            let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
            let participateCallVanUseCase = DefaultParticipateCallVanUseCase(repository: callVanRepository)
            let quitCallVanUseCase = DefaultQuitCallVanUseCase(repository: callVanRepository)
            let closeCallVanUseCase = DefaultCloseCallVanUseCase(repository: callVanRepository)
            let reopenCallVanUseCase = DefaultReopenCallVanUseCase(repository: callVanRepository)
            let completeCallVanUseCase = DefaultCompleteCallVanUseCase(repository: callVanRepository)
            let fetchCallVanSummaryUseCase = DefaultFetchCallVanSummaryUseCase(repository: callVanRepository)
            let fetchCallVanRestrictionUseCase = DefaultFetchCallVanRestrictionUseCase(repository: callVanRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
            let viewModel = CallVanListViewModel(
                checkLoginUseCase: checkLoginUseCase,
                fetchCallVanListUseCase: fetchCallVanListUseCase,
                fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
                participateCallVanUseCase: participateCallVanUseCase,
                quitCallVanUseCase: quitCallVanUseCase,
                closeCallVanUseCase: closeCallVanUseCase,
                reopenCallVanUseCase: reopenCallVanUseCase,
                completeCallVanUseCase: completeCallVanUseCase,
                fetchCallVanSummaryUseCase: fetchCallVanSummaryUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                fetchCallVanRestrictionUseCase: fetchCallVanRestrictionUseCase,
                fetchNotiListUseCase: fetchNotiListUseCase
            )
            let viewController = CallVanListViewController(viewModel: viewModel)
            if var viewControllers = navigationController?.viewControllers {
                viewControllers.insert(viewController, at: viewControllers.count - 1)
                navigationController?.setViewControllers(viewControllers, animated: false)
                navigationController?.popViewController(animated: true)
            }
        }
        showToastMessage(message: "작성되었습니다.", bottomInset: 75)
    }
}

extension CallVanPostViewController {
    
    private func configureView() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {        
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        descriptionLabel.do {
            $0.text = "※ 모든 항목을 다 작성해주세요."
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        postButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "작성 완료",
                attributes: [
                    .font : UIFont.appFont(.pretendardSemiBold, size: 16),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.neutral400)
            $0.layer.cornerRadius = 8
        }
    }
    private func setUpLayouts() {
        [placeView, dateView, timeView, participantsView].forEach {
            scrollContentView.addSubview($0)
        }
        scrollView.addSubview(scrollContentView)
        [scrollView, separatorView, descriptionLabel, postButton].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(separatorView.snp.top)
        }
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        placeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        dateView.snp.makeConstraints {
            $0.top.equalTo(placeView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        timeView.snp.makeConstraints {
            $0.top.equalTo(dateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        participantsView.snp.makeConstraints {
            $0.top.equalTo(timeView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        postButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.bottom.equalTo(postButton.snp.top).offset(-8)
            $0.centerX.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-16)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

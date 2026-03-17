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
    private let placeView = CallVanPostPlaceView()
    private let dateView = CallVanPostDateView()
    private let timeView = CallVanPostTimeView()
    private let participantsView = CallVanPostParticipantsView()
    
    private let separatorView = UIView()
    private let descriptionLabel = UILabel()
    private let postButton = UIButton()
    
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
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
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
                }
            }.store(in: &subscriptions)
        
        placeView.departureButtonTappedPublisher.sink { [weak self] in
            self?.presentDeparturePlaceBottomSheet()
        }.store(in: &subscriptions)
        
        placeView.arrivalButtonTappedPublisher.sink { [weak self] in
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
        
        dateView.dateButtonTappedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.timeView.dismissTimeDropDownView()
            }.store(in: &subscriptions)
        
        dateView.dateChangedPublisher.sink { [weak self] date in
            self?.inputSubject.send(.updateDepartureDate(date))
        }.store(in: &subscriptions)
        
        timeView.timeButtonTappedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dateView.dismissDateDropDownView()
            }.store(in: &subscriptions)
        
        timeView.timeChangedPublisher.sink { [weak self] time in
            self?.inputSubject.send(.updateDepartureTime(time))
        }.store(in: &subscriptions)
        
        participantsView.participantsChangedPublisher.sink { [weak self] participants in
            self?.inputSubject.send(.updateMaxParticipants(participants))
        }.store(in: &subscriptions)
    }
}

extension CallVanPostViewController {
    
    private func setAddTargets() {
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    @objc private func postButtonTapped() {
        postButton.isUserInteractionEnabled = false
        inputSubject.send(.postData)
    }
}

extension CallVanPostViewController {
    
    private func presentDeparturePlaceBottomSheet() {
        let onApplyButtonTapped: (CallVanPlace, String?)->Void = { [weak self] (place, customPlace) in
            guard let self else { return }
            placeView.updateDeparture(placeType: place, customPlace: customPlace)
            inputSubject.send(.updateDeparture(place, customPlace))
        }
        let contentView = CallVanPostPlaceBottomSheetView(
            title: .departure,
            place: viewModel.request.departureType,
            customPlace: viewModel.request.departureCustomName,
            onApplyButtonTapped: onApplyButtonTapped
        )
        let bottomSheetViewController = BottomSheetViewControllerB(
            contentView: contentView,
            dimColor: .black,
            dimAlpha: 0.7,
            backgroundColor: UIColor.appColor(.neutral0)
        )
        contentView.delegate = bottomSheetViewController
        present(bottomSheetViewController, animated: true)
    }
    private func presentArrivalPlaceBottomSheet() {
        let onApplyButtonTapped: (CallVanPlace, String?)->Void = { [weak self] (place, customPlace) in
            guard let self else { return }
            placeView.updateArrival(placeType: place, customPlace: customPlace)
            inputSubject.send(.updateArrival(place, customPlace))
        }
        let contentView = CallVanPostPlaceBottomSheetView(
            title: .arrival,
            place: viewModel.request.arrivalType,
            customPlace: viewModel.request.arrivalCustomName,
            onApplyButtonTapped: onApplyButtonTapped
        )
        let bottomSheetViewController = BottomSheetViewControllerB(
            contentView: contentView,
            dimColor: .black,
            dimAlpha: 0.7,
            backgroundColor: UIColor.appColor(.neutral0)
        )
        contentView.delegate = bottomSheetViewController
        present(bottomSheetViewController, animated: true)
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
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchCallVanListUseCase = DefaultFetchCallVanListUseCase(repository: callVanRepository)
            let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
            let participateCallVanUseCase = DefaultParticipateCallVanUseCase(repository: callVanRepository)
            let quitCallVanUseCase = DefaultQuitCallVanUseCase(repository: callVanRepository)
            let closeCallVanUseCase = DefaultCloseCallVanUseCase(repository: callVanRepository)
            let reopenCallVanUseCase = DefaultReopenCallVanUseCase(repository: callVanRepository)
            let completeCallVanUseCase = DefaultCompleteCallVanUseCase(repository: callVanRepository)
            let fetchCallVanSummaryUseCase = DefaultFetchCallVanSummaryUseCase(repository: callVanRepository)
            let viewModel = CallVanListViewModel(
                checkLoginUseCase: checkLoginUseCase,
                fetchCallVanListUseCase: fetchCallVanListUseCase,
                fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
                participateCallVanUseCase: participateCallVanUseCase,
                quitCallVanUseCase: quitCallVanUseCase,
                closeCallVanUseCase: closeCallVanUseCase,
                reopenCallVanUseCase: reopenCallVanUseCase,
                completeCallVanUseCase: completeCallVanUseCase,
                fetchCallVanSummaryUseCase: fetchCallVanSummaryUseCase
            )
            let viewController = CallVanListViewController(viewModel: viewModel)
            if var viewControllers = navigationController?.viewControllers {
                viewControllers.insert(viewController, at: viewControllers.count - 1)
                navigationController?.setViewControllers(viewControllers, animated: false)
                navigationController?.popViewController(animated: true)
            }
        }
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
        [placeView, participantsView, separatorView, descriptionLabel, postButton,
         timeView, dateView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        placeView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
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

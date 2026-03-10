//
//  CallVanDataViewController.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanDataViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSubject = PassthroughSubject<CallVanDataViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: CallVanDataViewModel
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let dataView = CallVanDataView()
    private let participantsTableView = CallVanDataTableView()
    private let separatorView = UIView()
    private let enterChatRoomButton = UIButton()
    
    // MARK: - Initializer
    init(viewModel: CallVanDataViewModel) {
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
        configureView()
        bind()
        configureNavigationBar(style: .empty)
        configureRightBarButton()
        addGesture()
        setAddTargets()
        inputSubject.send(.viewDidLoad)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        participantsTableView.closeReportButton()
    }
}

extension CallVanDataViewController {
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .update(callVanData):
                dataView.configure(callVanData: callVanData)
                participantsTableView.configure(participants: callVanData.participants)
            }
        }.store(in: &subscriptions)
        
        participantsTableView.reportButtonTappedPublisher.sink { [weak self] userId in
            self?.navigateToReport(userId)
        }.store(in: &subscriptions)
    }
}

extension CallVanDataViewController {
    
    private func setAddTargets() {
        enterChatRoomButton.addTarget(self, action: #selector(enterChatRoomButtonTapped), for: .touchUpInside)
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAround))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func enterChatRoomButtonTapped() {
        let viewModel = CallVanChatViewModel(postId: viewModel.postId)
        let viewController = CallVanChatViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func didTapAround() {
        participantsTableView.closeReportButton()
    }
}

extension CallVanDataViewController {
    
    private func configureRightBarButton(alert: Bool = false) {
        let bellButton = UIBarButtonItem(image: UIImage.appImage(asset: .bell)?.withRenderingMode(.alwaysOriginal)
                                         , style: .plain, target: self, action: #selector(bellButtonTapped))
        navigationItem.rightBarButtonItem = bellButton
    }
    
    @objc private func bellButtonTapped() {
        // TODO
    }
}

extension CallVanDataViewController {
    
    private func navigateToReport(_ userId: Int) {
        let viewModel = CallVanReportViewModel(reportedUserId: userId)
        let viewController = CallVanReportReasonViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CallVanDataViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        
        participantsTableView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
        }
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        enterChatRoomButton.do {
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.setAttributedTitle(NSAttributedString(
                string: "단체 채팅방 입장",
                attributes: [
                    .font : UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.layer.cornerRadius = 8
        }
    }
    
    private func setUpLayouts() {
        [dataView, participantsTableView].forEach {
            scrollView.addSubview($0)
        }
        [scrollView, separatorView, enterChatRoomButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(separatorView.snp.top)
        }
        dataView.snp.makeConstraints {
            $0.width.equalTo(view)
            $0.top.leading.trailing.equalTo(scrollView.contentLayoutGuide)
        }
        participantsTableView.snp.makeConstraints {
            $0.height.equalTo(56 * 8)
            $0.width.equalTo(view)
            $0.top.equalTo(dataView.snp.bottom)
            $0.bottom.leading.trailing.equalTo(scrollView.contentLayoutGuide)
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(enterChatRoomButton.snp.top).offset(-24)
        }
        enterChatRoomButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
}

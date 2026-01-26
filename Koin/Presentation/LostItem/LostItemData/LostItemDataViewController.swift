//
//  LostItemDataViewController.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import Combine
import Then
import UIKit

protocol LostItemDataViewControllerDelegate: AnyObject {
    func updateState(foundDataId id: Int)
    func updateState(reportedDataId id: Int)
    func updateState(deletedId id: Int)
    func updateState(updatedId id: Int, lostItemData: LostItemData)
}

final class LostItemDataViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: LostItemDataViewModel
    private let inputSubject = PassthroughSubject<LostItemDataViewModel.Input, Never>()
    private var subscription: Set<AnyCancellable> = []
    weak var delegate: LostItemDataViewControllerDelegate?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let headerView = LostItemDataHeaderView()
    private let contentView = LostItemDataContentView()
    private let buttonsView = LostItemDataButtonsView()
    private let recentHeaderView = LostItemDataRecentHeaderView()
    private let lostItemDataTableView = LostItemDataRecentTableView()
    
    // MARK: - Initializer
    init(viewModel: LostItemDataViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "분실물"
        configureView()
        bind()
        inputSubject.send(.loadList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        inputSubject.send(.loadData)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .updateData(let lostItemData):
                self.headerView.configure(lostItemData: lostItemData)
                self.contentView.configure(images: lostItemData.images, content: lostItemData.content, isCouncil: lostItemData.isCouncil)
                self.buttonsView.configure(isMine: lostItemData.isMine, isCouncil: lostItemData.isCouncil, isFound: lostItemData.isFound)
            case .updateList(let lostItemListData):
                self.lostItemDataTableView.configure(lostItemListData: lostItemListData)
            case .appendList(let lostItemListData):
                self.lostItemDataTableView.appendList(lostItemListData: lostItemListData)
            case .showToast(let message):
                self.showToast(message: message)
            case .changeState(let id):
                self.delegate?.updateState(foundDataId: id)
                self.headerView.changeState()
                self.buttonsView.changeState()
                self.lostItemDataTableView.updateState(foundDataId: id)
            case .deletedData(let id):
                self.delegate?.updateState(deletedId: id)
                self.lostItemDataTableView.updateState(deletedId: id)
            case .popViewController:
                self.navigationController?.popViewController(animated: true)
            case .checkedLogin((let option, let isLoggedIn)):
                switch option {
                case .chat:
                    if !isLoggedIn { showLoginToChatModal() }
                case .report:
                    isLoggedIn ? navigateToReport() : showLoginToReportModal()
                }
            case .navigateToChat(let createChatRoomResponse):
                navigateToChat(createChatRoomResponse)
            }
        }.store(in: &subscription)
        
        lostItemDataTableView.cellTappedPublisher.sink { [weak self] id in
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
            let chatRepository = DefaultChatRepository(service: DefaultChatService())
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
            let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
            let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
            let createChatRoomUseCase = DefaultCreateChatRoomUseCase(chatRepository: chatRepository)
            let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
            let viewModel = LostItemDataViewModel(
                checkLoginUseCase: checkLoginUseCase,
                fetchLostItemDataUseCase: fetchLostItemDataUseCase,
                fetchLostItemListUseCase: fetchLostItemListUseCase,
                changeLostItemStateUseCase: changeLostItemStateUseCase,
                deleteLostItemUseCase: deleteLostItemUseCase,
                createChatRoomUseCase: createChatRoomUseCase,
                id: id)
            let viewController = LostItemDataViewController(viewModel: viewModel)
            viewController.delegate = self
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscription)
        
        contentView.imageTapPublisher.sink { [weak self] imageUrls, indexPath in
            guard let self else { return }
            let viewController = ZoomedImageViewControllerB()
            viewController.configure(
                urls: imageUrls,
                initialIndexPath: indexPath)
            navigationController?.present(viewController, animated: true)
        }.store(in: &subscription)
        
        buttonsView.listButtonTappedPublisher.sink { [weak self] in
            self?.popToLostItemListViewController()
        }.store(in: &subscription)
        
        buttonsView.deleteButtonTappedPublisher.sink { [weak self] in
            self?.showDeleteModal()
        }.store(in: &subscription)
        
        buttonsView.editButtonTappedPublisher.sink { [weak self] in
            self?.navigateToEdit()
        }.store(in: &subscription)
        
        buttonsView.changeStateButtonTappedPublisher.sink { [weak self] in
            self?.showChangeStateModal()
        }.store(in: &subscription)
        
        buttonsView.chatButtonTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.checkLogIn(.chat))
        }.store(in: &subscription)
        
        buttonsView.reportButtonTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.checkLogIn(.report))
        }.store(in: &subscription)
        
        lostItemDataTableView.loadMoreListPublisher.sink { [weak self] in
            self?.inputSubject.send(.loadMoreList)
        }.store(in: &subscription)
    }
}

extension LostItemDataViewController: EditLostItemViewControllerDelegate {
    
    func updateData(lostItemData: LostItemData) {
        headerView.configure(lostItemData: lostItemData)
        contentView.configure(images: lostItemData.images, content: lostItemData.content, isCouncil: lostItemData.isCouncil)
        buttonsView.configure(isMine: lostItemData.isMine, isCouncil: lostItemData.isCouncil, isFound: lostItemData.isFound)
        delegate?.updateState(updatedId: viewModel.id, lostItemData: lostItemData)
    }
}

extension LostItemDataViewController: LostItemDataViewControllerDelegate, ReportLostItemViewControllerDelegate {
    
    func updateState(foundDataId id: Int) {
        delegate?.updateState(foundDataId: id)
        lostItemDataTableView.updateState(foundDataId: id)
    }
    
    func updateState(reportedDataId id: Int) {        
        delegate?.updateState(reportedDataId: id)
        lostItemDataTableView.updateState(reportedDataId: id)
    }
    
    func updateState(deletedId id: Int) {
        delegate?.updateState(deletedId: id)
        lostItemDataTableView.updateState(deletedId: id)
    }
    
    func updateState(updatedId id: Int, lostItemData: LostItemData) {
        delegate?.updateState(updatedId: id, lostItemData: lostItemData)
        lostItemDataTableView.updateState(updatedId: id, lostItemData: lostItemData)
    }
}

extension LostItemDataViewController {
    
    private func popToLostItemListViewController() {
        if let lostItemListViewController = navigationController?.viewControllers.first(where: {
            $0 is LostItemListViewController
        }) {
            navigationController?.popToViewController(lostItemListViewController, animated: true)
        }
        
        else {
            guard let homeViewController = navigationController?.viewControllers.first(where: {
                $0 is HomeViewController
            }) else {
                return
            }
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchLostItemItemUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
            let viewModel = LostItemListViewModel(checkLoginUseCase: checkLoginUseCase, fetchLostItemListUseCase: fetchLostItemItemUseCase)
            let lostItemListViewController = LostItemListViewController(viewModel: viewModel)
            navigationController?.setViewControllers([homeViewController, lostItemListViewController], animated: true)
        }
    }
    
    private func showDeleteModal() {
        let onRightButtonTapped: ()->Void = { [weak self] in
            self?.inputSubject.send(.deleteData)
        }
        let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 162, title: "삭제 시 되돌릴 수 없습니다.\n게시글을 삭제하시겠습니까?", titleColor: .appColor(.neutral600), rightButtonText: "확인")
        modalViewController.modalPresentationStyle = .overFullScreen
        modalViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(modalViewController, animated: true)
    }
    
    private func navigateToEdit() {
        let service = DefaultLostItemService()
        let repository = DefaultLostItemRepository(service: service)
        let updateLostItemUseCase = DefaultUpdateLostItemUseCase(repository: repository)
        guard let lostItemData = viewModel.lostItemData else {
            return
        }
        let viewModel = EditLostItemViewModel(updateLostItemUseCase: updateLostItemUseCase, lostItemData: lostItemData)
        let viewController = EditLostItemViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showChangeStateModal() {
        let onRightButtonTapped: ()->Void = { [weak self] in
            guard let self else { return }
            inputSubject.send(.changeState(viewModel.id))
        }
        let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 162, title: "상태 변경 시 되돌릴 수 없습니다.\n찾음으로 변경하시겠습니까?", titleColor: .appColor(.neutral600), rightButtonText: "확인")
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(modalViewController, animated: true)
    }
    
    private func navigateToChat(_ createChatRoomResponse: CreateChatRoomResponse) {
        let chatViewModel = ChatViewModel(
            articleId: createChatRoomResponse.articleId,
            chatRoomId: createChatRoomResponse.chatRoomId,
            articleTitle: createChatRoomResponse.articleTitle
        )
        let viewController = ChatViewController(viewModel: chatViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLoginToChatModal() {
        let onRightButtonTapped: ()->Void = { [weak self] in
            let repository = GA4AnalyticsRepository(service: GA4AnalyticsService())
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: repository)
            let loginUseCase = DefaultLoginUseCase(userRepository: userRepository)
            let viewModel = LoginViewModel(loginUseCase: loginUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
            let viewController = LoginViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 208, paddingBetweenLabels: 16, title: "쪽지를 보내려면\n로그인이 필요해요.", subTitle: "로그인 후 대화를 시작하세요!", titleColor: .appColor(.neutral600), subTitleColor: .appColor(.gray))
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(modalViewController, animated: true)
    }
    
    private func showLoginToReportModal() {
        let onRightButtonTapped: ()->Void = { [weak self] in
            let repository = GA4AnalyticsRepository(service: GA4AnalyticsService())
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: repository)
            let loginUseCase = DefaultLoginUseCase(userRepository: userRepository)
            let viewModel = LoginViewModel(loginUseCase: loginUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
            let viewController = LoginViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 208, paddingBetweenLabels: 16, title: "게시글을 신고하려면\n로그인이 필요해요.", subTitle: "로그인 후 이용해주세요.", titleColor: .appColor(.neutral600), subTitleColor: .appColor(.gray))
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(modalViewController, animated: true)
    }
    
    private func navigateToReport() {
        let viewModel = ReportLostItemViewModel(noticeId: viewModel.id)
        let viewController = ReportLostItemViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LostItemDataViewController {
    
    private func setUpLayouts() {
        [headerView, contentView, buttonsView, recentHeaderView, lostItemDataTableView].forEach {
            scrollContentView.addSubview($0)
        }
        [scrollContentView].forEach {
            scrollView.addSubview($0)
        }
        [scrollView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        scrollContentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
            $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.height)
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(scrollContentView)
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalTo(scrollContentView)
        }
        buttonsView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom)
            $0.leading.trailing.equalTo(scrollContentView)
        }
        recentHeaderView.snp.makeConstraints {
            $0.top.equalTo(buttonsView.snp.bottom)
            $0.leading.trailing.equalTo(scrollContentView)
            $0.height.equalTo(54)
        }
        lostItemDataTableView.snp.makeConstraints {
            $0.top.equalTo(recentHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(scrollContentView)
            $0.height.greaterThanOrEqualTo(lostItemDataTableView.rowHeight * 4.6)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .appColor(.neutral0)
    }
}

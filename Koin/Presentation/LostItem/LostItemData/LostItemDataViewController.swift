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
    private let lostItemDataTableView = LostItemDataTableView()
    
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
        inputSubject.send(.loadData)
        inputSubject.send(.loadList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .updateData(let lostItemData):
                self.lostItemDataTableView.configure(lostItemData: lostItemData)
            case .updateList(let lostItemListData):
                self.lostItemDataTableView.configure(lostItemListData: lostItemListData)
            case .appendList(let lostItemListData):
                self.lostItemDataTableView.appendList(lostItemListData: lostItemListData)
            case .navigateToChat:
                self.navigateToChat()
            case .showLoginModal:
                self.showLoginModal()
            case .showToast(let message):
                self.showToast(message: message)
            case .changeState:
                self.lostItemDataTableView.changeState()
            case .deletedData(let id):
                self.delegate?.updateState(deletedId: id)
            case .popViewController:
                self.navigationController?.popViewController(animated: true)
            }
        }.store(in: &subscription)
        
        lostItemDataTableView.cellTappedPublisher.sink { [weak self] id in
            let userService = DefaultUserService()
            let lostItemService = DefaultLostItemService()
            let userRepository = DefaultUserRepository(service: userService)
            let lostItemRepository = DefaultLostItemRepository(service: lostItemService)
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
            let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
            let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
            let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
            let viewModel = LostItemDataViewModel(
                checkLoginUseCase: checkLoginUseCase,
                fetchLostItemDataUseCase: fetchLostItemDataUseCase,
                fetchLostItemListUseCase: fetchLostItemListUseCase,
                changeLostItemStateUseCase: changeLostItemStateUseCase,
                deleteLostItemUseCase: deleteLostItemUseCase,
                id: id)
            let viewController = LostItemDataViewController(viewModel: viewModel)
            viewController.delegate = self
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscription)
        
        lostItemDataTableView.imageTapPublisher.sink { [weak self] (images: [Image], indexPath: IndexPath) in
            guard let self else { return }
            let viewController = ZoomedImageViewControllerB()
            viewController.configure(
                urls: images.map { return $0.imageUrl },
                initialIndexPath: indexPath)
            navigationController?.present(viewController, animated: true)
        }.store(in: &subscription)
        
        lostItemDataTableView.listButtonTappedPublisher.sink { [weak self] in
            self?.popToLostItemListViewController()
        }.store(in: &subscription)
        
        lostItemDataTableView.deleteButtonTappedPublisher.sink { [weak self] in
            self?.showDeleteModal()
        }.store(in: &subscription)
        
        lostItemDataTableView.editButtonTappedPublisher.sink { [weak self] in
            self?.navigateToEdit()
        }.store(in: &subscription)
        
        lostItemDataTableView.changeStateButtonTappedPublisher.sink { [weak self] id in
            self?.showChangeStateModal(id)
        }.store(in: &subscription)
        
        lostItemDataTableView.chatButtonTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.checkLogIn)
        }.store(in: &subscription)
        
        lostItemDataTableView.reportButtonTappedPublisher.sink { [weak self] id in
            self?.navigateToReport(id)
        }.store(in: &subscription)
        
        lostItemDataTableView.loadMoreListPublisher.sink { [weak self] in
            self?.inputSubject.send(.loadMoreList)
        }.store(in: &subscription)
    }
}

extension LostItemDataViewController: EditLostItemViewControllerDelegate {
    
    func updateData(lostItemData: LostItemData) {
        lostItemDataTableView.configure(lostItemData: lostItemData)
        delegate?.updateState(updatedId: viewModel.id, lostItemData: lostItemData)
    }
}

extension LostItemDataViewController: LostItemDataViewControllerDelegate {
    
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
            let viewModel = LostItemListViewModel(checkLoginUseCase: checkLoginUseCase, fetchLostItemItemUseCase: fetchLostItemItemUseCase)
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
        guard let lostItemData = lostItemDataTableView.lostItemData else {
            return
        }
        let viewModel = EditLostItemViewModel(updateLostItemUseCase: updateLostItemUseCase, lostItemData: lostItemData)
        let viewController = EditLostItemViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showChangeStateModal(_ id: Int) {
        let onRightButtonTapped: ()->Void = { [weak self] in
            self?.inputSubject.send(.changeState(id))
            self?.delegate?.updateState(foundDataId: id)
        }
        let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 162, title: "상태 변경 시 되돌릴 수 없습니다.\n찾음으로 변경하시겠습니까?", titleColor: .appColor(.neutral600), rightButtonText: "확인")
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(modalViewController, animated: true)
    }
    
    private func navigateToChat() {
        let articleId = 0, chatRoomId = 0, articleTitle = ""
        let chatViewModel = ChatViewModel(articleId: articleId, chatRoomId: chatRoomId, articleTitle: articleTitle)
        let viewController = ChatViewController(viewModel: chatViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLoginModal() {
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
    
    private func navigateToReport(_ id: Int) {
        let viewModel = ReportLostItemViewModel(noticeId: id)
        let onSuccess: (Int)->Void = { [weak self] id in
            self?.delegate?.updateState(reportedDataId: id)
        }
        let viewController = ReportLostItemViewController(viewModel: viewModel, onSuccess: onSuccess)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LostItemDataViewController {
    
    private func configureView() {
        [lostItemDataTableView].forEach {
            view.addSubview($0)
        }
        lostItemDataTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

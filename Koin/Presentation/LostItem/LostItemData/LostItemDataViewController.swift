//
//  LostItemDataViewController.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import Combine
import Then
import UIKit

final class LostItemDataViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: LostItemDataViewModel
    private var subscription: Set<AnyCancellable> = []
    private var images: [Image] = [
        Image(id: 159, imageUrl: "https://stage-static.koreatech.in/upload/LOST_ITEMS/2026/1/18/18f40175-92c3-41ef-bb21-59b73303b333/tablet.png"),
        Image(id: 159, imageUrl: "https://stage-static.koreatech.in/upload/LOST_ITEMS/2026/1/18/18f40175-92c3-41ef-bb21-59b73303b333/tablet.png")
    ]
    
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
        configureView()
        bind()
        title = "분실물"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        
        lostItemDataTableView.configure(
            lostItemData: LostItemData(id: 0, boardID: 0, type: "분실", category: "카드", foundPlace: "안경점", foundDate: "2022-02-02", content: "아이패드 9세대\n하늘색 케이스에 캐릭터가 붙어있고 에플팬스 1세대도 함께 잇습니다", author: "익명",
                                       isCouncil: false,
                                       isMine: true,
                                       isFound: false,
                images: [
                    Image(id: 159, imageUrl: "https://stage-static.koreatech.in/upload/LOST_ITEMS/2026/1/18/18f40175-92c3-41ef-bb21-59b73303b333/tablet.png")
                ],
                                       prevID: 0, nextID: 0, registeredAt: "2022-02-02", updatedAt: ""),
            lostItemArticle: [
                LostItemArticle(id: 0, type: .found, category: "지갑", foundPlace: "동방", foundDate: "2022-02-02", content: nil, author: "ㅇㅇ", registeredAt: "2022-02-02", isReported: true, isFound: true),
                LostItemArticle(id: 0, type: .found, category: "지갑", foundPlace: "동방", foundDate: "2022-02-02",
                                content: "아이패드 9세대\n하늘색 케이스에 캐릭터가 붙어있고 에플팬스 1세대도 함께 잇습니다",
            author: "ㅇㅇ", registeredAt: "2022-02-02", isReported: true, isFound: false)
            ]
        )
    }
    
    private func bind() {
        lostItemDataTableView.cellTappedPublisher.sink { [weak self] id in
            let viewModel = LostItemDataViewModel()
            let viewController = LostItemDataViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscription)
        
        lostItemDataTableView.imageTapPublisher.sink { [weak self] indexPath in
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
            let userService = DefaultUserService()
            let userRepository = DefaultUserRepository(service: userService)
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let viewModel = LostItemListViewModel(checkLoginUseCase: checkLoginUseCase)
            let lostItemListViewController = LostItemListViewController(viewModel: viewModel)
            navigationController?.setViewControllers([homeViewController, lostItemListViewController], animated: true)
        }
    }
    
    private func showDeleteModal() {
        let onRightButtonTapped: ()->Void = { [weak self] in
            // TODO: ViewModel 호출
        }
        let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 162, title: "삭제 시 되돌릴 수 없습니다.\n게시글을 삭제하시겠습니까?", titleColor: .appColor(.neutral600), rightButtonText: "확인")
        modalViewController.modalPresentationStyle = .overFullScreen
        modalViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(modalViewController, animated: true)
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

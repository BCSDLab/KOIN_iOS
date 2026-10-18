//
//  DiningHostingController.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import SwiftUI

final class DiningHostingController: UIHostingController<DiningView>, HostingControllerProtocol {
    
    // MARK: - UI Components
    private lazy var coopInfoBarButton = UIBarButtonItem(
        image: .appImage(asset: .coopInfo),
        style: .plain,
        target: self,
        action: #selector(didTapCoopInfoButton)
    )
    
    // MARK: - Initializer
    override init(rootView: DiningView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "식단"
        configureNavigationBar()
    }
    
    // MARK: - Execute
    func execute(action: RootView.Action) {
        switch action {
        case .showToastMessage(let message):
            showToastMessage(message: message)
        case .showZoomedImage(let imageUrl):
            showZoomedImage(imageUrl: imageUrl)
        }
    }
}

extension DiningHostingController {
    private func configureNavigationBar() {
        configureNavigationBar(style: .empty)
        navigationItem.setRightBarButtonItems([coopInfoBarButton], animated: true)
    }
    
    @objc private func didTapCoopInfoButton() {
        navigateToCoopInfo()
    }
}

extension DiningHostingController {
    private func navigateToCoopInfo() {
        let diningRepository = DefaultDiningRepository(
            diningService: DefaultDiningService(),
            shareService: KakaoShareService()
        )
        let fetchCoopShopListUseCase = DefaultFetchCoopShopListUseCase(diningRepository: diningRepository)
        let viewModel = DiningNoticeViewModel(fetchCoopShopListUseCase: fetchCoopShopListUseCase)
        let viewController = DiningNoticeViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DiningHostingController {
    private func showZoomedImage(imageUrl: String) {
        let zoomedImageViewController = ZoomedImageViewControllerB(shouldShowTitle: false)
        zoomedImageViewController.configure(url: imageUrl)
        zoomedImageViewController.modalTransitionStyle = .coverVertical
        zoomedImageViewController.modalPresentationStyle = .overFullScreen
        present(zoomedImageViewController, animated: true)
    }
}

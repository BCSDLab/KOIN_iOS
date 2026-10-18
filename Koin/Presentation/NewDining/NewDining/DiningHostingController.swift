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
        case .presentNotiBottomSheet(let initialValue):
            presentNotiBottomSheet(initialValue)
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

extension DiningHostingController {
    private func presentNotiBottomSheet(_ initialValue: DiningNoti) {
        let contentView = DiningNotiBottomSheetContentView(
            onSoldOutSwitchToggled: rootView.didTapSoldOutSwitch,
            onImageUploadSwitchToggled: rootView.didTapImageUploadSwitch,
            onNotiButtonTapped: navigateToNoti,
            initialValue: initialValue
        )
        let bottomSheetViewController = BottomSheetViewControllerB(contentView: contentView)
        contentView.delegate = bottomSheetViewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.present(bottomSheetViewController, animated: false)
        }
    }
    
    private func navigateToNoti() {
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewController = NotiViewController(viewModel: NotiViewModel(changeNotiUseCase: changeNotiUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, fetchNotiListUseCase: fetchNotiListUseCase, logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        navigationController?.pushViewController(viewController, animated: true)
    }
}

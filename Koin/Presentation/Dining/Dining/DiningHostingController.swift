//
//  DiningHostingController.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import SwiftUI
import PhotosUI
import SnapKit
import Then

final class DiningHostingController: UIHostingController<DiningView>, HostingControllerProtocol {
    
    // MARK: - Modal
    private var modalView: DiningReportModalView?
    
    // MARK: - UI Components
    private lazy var reportButton = UIButton().then {
        $0.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
    }
    private lazy var reportBarButton = UIBarButtonItem(customView: reportButton)
    private lazy var coopInfoBarButton = UIBarButtonItem(
        image: .appImage(asset: .coopInfo),
        style: .plain,
        target: self,
        action: #selector(didTapCoopInfoButton)
    )
    private lazy var reportTooltipImageView = CancelableImageView().then {
        if let image = UIImage.appImage(asset: DiningReportAbTest.nav.imageAsset) {
            $0.setUpImage(image: image)
        }
        $0.isHidden = true
        $0.onXButtonTapped = didTapCloseReportTooltip
        $0.onImageTapped = didTapReportButton
    }
    
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
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateReportTooltipPosition()
    }
    
    // MARK: - Execute
    func execute(action: RootView.Action) {
        switch action {
        case .showToastMessage(let message):
            showToastMessage(message: message)
        case .showReportBarButton:
            showReportBarButton()
        case .showReportBarButtonTooltip:
            showReportBarButtonTooltip()
        case .showReportModal:
            showReportModal()
        case .didFinishReporting:
            dismiss(animated: true)
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
    
    private func showReportBarButton() {
        let rightBarButtonItems = [coopInfoBarButton, reportBarButton]
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
    }
    
    private func showReportBarButtonTooltip() {
        reportTooltipImageView.isHidden = false
    }
    
    private func updateReportTooltipPosition() {
        guard navigationItem.rightBarButtonItems?.contains(reportBarButton) == true else {
            return
        }
        let reportButtonRect = reportButton.convert(
            reportButton.bounds,
            to: view
        )
        
        reportTooltipImageView.frame.origin = CGPoint(
            x: reportButtonRect.minX - 135,
            y: reportButtonRect.maxY + 10
        )
    }
    
    @objc private func didTapReportButton() {
        showReportModal()
    }
    
    @objc private func didTapCoopInfoButton() {
        navigateToCoopInfo()
    }

    private func didTapCloseReportTooltip() {
        reportTooltipImageView.removeFromSuperview()
        rootView.didTapCloseReportTooltip()
    }
}

extension DiningHostingController {
    private func onCompleteButtonTapped(
        selectedItem: DiningItem,
        evidenceImage: UIImage
    ) {
        guard let imageData = evidenceImage.jpegData(compressionQuality: 0.5) else {
            return
        }
        rootView.didTapReport(
            selectedItem: selectedItem,
            evidenceImage: imageData
        )
    }
}

extension DiningHostingController {
    private func configureView() {
        view.addSubview(reportTooltipImageView)
        
        reportButton.setImage(.appImage(asset: .diningReport), for: .normal)
        
        reportTooltipImageView.snp.makeConstraints {
            $0.width.equalTo(171)
            $0.height.equalTo(62)
        }
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
    
    private func showReportModal() {
        guard !rootView.currentDiningItems.isEmpty else {
            showToastMessage(message: "학생식당 운영시간이 아닙니다.")
            return
        }
        self.modalView = makeModalView()
        presentReportModalViewController()
    }
    
    private func makeModalView() -> DiningReportModalView {
        return DiningReportModalView(
            diningItems: rootView.currentDiningItems,
            onDismissButtonTapped: { [weak self] in
                self?.dismiss(animated: true)
            },
            onSelectImageButtonTapped: checkAndPresentPicker,
            onCompleteButtonTapped: onCompleteButtonTapped
        )
    }
    
    private func presentReportModalViewController() {
        guard let modalView else {
            return
        }
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .custom(customView: modalView),
            button: .none,
            layout: .init(
                width: 340,
                contentTopPadding: 16,
                contentHorizontalPadding: 20,
                contentBottomPadding: 16
            )
        ))
        present(modalViewController, animated: true)
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

extension DiningHostingController: PHPickerViewControllerDelegate {
    private func presentPickerViewController() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        presentedViewController?.present(picker, animated: true, completion: nil)
    }
    
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let image = image as? UIImage else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.modalView?.configure(evidenceImage: image)
                }
            }
        }
    }
}

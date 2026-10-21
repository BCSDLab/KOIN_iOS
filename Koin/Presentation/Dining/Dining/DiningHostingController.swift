//
//  DiningHostingController.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
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
        rootView.makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.Dining.cafeteriaDiningSoldoutStart,
            category: .click,
            value: DiningReportAbTest.nav.logValue
        )
        showReportModal()
    }
    
    @objc private func didTapCoopInfoButton() {
        rootView.makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.Dining.cafeteriaInfo,
            category: .click,
            value: "학생식당정보"
        )
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
                guard let self else {
                    return
                }
                if let reportAbTestName {
                    let place = modalView?.selectedItem.map { "_\($0.place.name)" } ?? ""
                    rootView.makeLogAnalyticsEvent(
                        label: EventParameter.EventLabel.Campus.Dining.cafeteriaDiningSoldoutExit,
                        category: .click,
                        value: "\(reportAbTestName)\(place)_이탈"
                    )
                }
                dismiss(animated: true)
            },
            onPlaceSelected: { [weak self] item in
                guard let self, let reportAbTest = rootView.reportAbTest else {
                    return
                }
                rootView.makeLogAnalyticsEvent(
                    label: EventParameter.EventLabel.Campus.Dining.cafeteriaDiningSoldoutSelect,
                    category: .select,
                    value: "\(reportAbTest.logValue)_\(item.place.name)"
                )
            },
            onSelectImageButtonTapped: { [weak self] in
                guard let self else {
                    return
                }
                if let reportAbTestName {
                    rootView.makeLogAnalyticsEvent(
                        label: EventParameter.EventLabel.Campus.Dining.cafeteriaDiningSoldoutPhoto,
                        category: .click,
                        value: "\(reportAbTestName)_\(modalView?.selectedItem?.place.name ?? "None")"
                    )
                }
                checkAndPresentPicker()
            },
            onCompleteButtonTapped: onCompleteButtonTapped
        )
    }
    
    private var reportAbTestName: String? {
        rootView.reportAbTest?.logValue
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

extension DiningHostingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func checkAndPresentPicker() {
        do {
            guard UIImagePickerController.isSourceTypeAvailable(.camera),
                  UIImagePickerController.isCameraDeviceAvailable(.rear) else {
                throw ErrorResponse.cameraUnavailable
            }
            
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .authorized:
                presentPickerController()
            case .notDetermined:
                requestCameraPermission { [weak self] isPermitted in
                    guard let self else { return }
                    if isPermitted {
                        presentPickerController()
                    } else {
                        showSettingToast()
                    }
                }
            case .restricted:
                throw ErrorResponse.cameraUnavailable
            default:
                showSettingToast()
            }
        } catch {
            showToastMessage(message: (error as? ErrorResponse)?.message ?? error.localizedDescription)
        }
    }
    
    private func presentPickerController() {
        DispatchQueue.main.async { [weak self] in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.cameraDevice = .rear
            picker.mediaTypes = [UTType.image.identifier]
            
            picker.delegate = self
            
            self?.presentedViewController?.present(picker, animated: true)
        }
    }
    
    private func requestCameraPermission(completion: @escaping (Bool)->Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
    }
    
    private func showSettingToast() {
        let action: ()->Void = {
            if let appSetting = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(appSetting) {
                UIApplication.shared.open(appSetting)
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.showToastMessageWithButton(
                message: "카메라 권한을 허용해주세요.",
                buttonTitle: "설정으로 이동",
                buttonAction: action
            )
        }
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            modalView?.configure(evidenceImage: image)
        }
    }
}

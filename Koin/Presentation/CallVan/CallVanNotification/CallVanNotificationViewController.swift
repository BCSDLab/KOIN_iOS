//
//  CallVanNotificationViewController.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanNotificationViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CallVanNotificationViewModel
    
    // MARK: - UI Components
    private let notificationTableView = CallVanNotificationTableView()
    private let emptyView = CallVanNotificationEmptyView()
    
    // MARK: - Initializer
    init(viewModel: CallVanNotificationViewModel) {
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
        configureNavigationBar(style: .empty)
        configureRightBarButton()
    }
}

extension CallVanNotificationViewController {
    
    private func configureRightBarButton() {
        let rightBarButton = UIBarButtonItem(
            image: UIImage.appImage(asset: .threeCircle),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func rightBarButtonTapped() {
        let onReadButtonTapped = { }
        let onDeleteButtonTapped = { [weak self] in
            guard let self else { return }
            let subTitleLabel = UILabel().then {
                $0.text = "삭제한 알림은 되돌릴 수 없습니다."
                $0.font = UIFont.appFont(.pretendardRegular, size: 14)
                $0.textColor = UIColor.appColor(.neutral600)
            }
            subTitleLabel.snp.makeConstraints {
                $0.height.equalTo(22)
            }
            let onMainButtonTapped = {}
            let contentViewController = CallVanBottomSheetViewController(
                titleText: "알림을 모두 삭제할까요?",
                subTitleLabel: subTitleLabel,
                mainButtonText: "예",
                closeButtonText: "아니요",
                onMainButtonTapped: onMainButtonTapped)
            let bottomSheetViewController = BottomSheetViewController(
                contentViewController: contentViewController,
                defaultHeight: 233 + view.safeAreaInsets.bottom
            )
            bottomSheetViewController.modalTransitionStyle = .crossDissolve
            bottomSheetViewController.modalPresentationStyle = .overFullScreen
            present(bottomSheetViewController, animated: true)
        }
        let dropdownViewController = CallVanNotificationDropdownViewController(
            onReadButtonTapped: onReadButtonTapped,
            onDeleteButtonTapped: onDeleteButtonTapped
        )
        dropdownViewController.modalTransitionStyle = .crossDissolve
        dropdownViewController.modalPresentationStyle = .overFullScreen
        present(dropdownViewController, animated: true)
    }
}

extension CallVanNotificationViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
    }
    
    private func setUpLayouts() {
        [notificationTableView, emptyView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        notificationTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

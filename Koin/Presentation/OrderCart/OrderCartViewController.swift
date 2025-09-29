//
//  OrderCartViewController.swift
//  koin
//
//  Created by 홍기정 on 9/25/25.
//

import UIKit

final class OrderCartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OrderCartViewModel
    
    // MARK: - Components
    private let emptyView = EmptyView()
    private let segmentedControl = OrderCartSegmentedControl()
    private let descriptionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    private let descriptionImageView = UIImageView(image: .appImage(asset: .incorrectInfo)?.withRenderingMode(.alwaysTemplate).withTintColor(.appColor(.new500)))
    private let descriptionLabel = UILabel().then {
        $0.text = "이 가게는 포장주문만 가능해요"
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.new500)
    }
    private let tableView = OrderCartTableView().then {
        $0.sectionHeaderTopPadding = 0
    }
    
    // MARK: - Initializer
    init(viewModel: OrderCartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRightBarButton()
        configureNavigationBar(style: .order)
        
        segmentedControl.configure(isDeliveryAvailable: true, isPickupAvailable: true)
    }
}

extension OrderCartViewController {
    
    private func configureRightBarButton() {
        let rightBarButton = UIBarButtonItem(title: "전체삭제", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        rightBarButton.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.new500),
            .font: UIFont.appFont(.pretendardSemiBold, size: 14)
        ],for: .normal)
        rightBarButton.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.new500),
            .font: UIFont.appFont(.pretendardSemiBold, size: 14)
        ],for: .highlighted)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    // MARK: - @objc
    @objc private func rightBarButtonTapped() {
        // 전체삭제 로직
        print("rightBarButtonTapped")
    }
}

extension OrderCartViewController {
    
    private func setUpLayouts() {
        [descriptionImageView, descriptionLabel].forEach {
            descriptionStackView.addArrangedSubview($0)
        }
        
        [emptyView, segmentedControl, descriptionStackView, tableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        segmentedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.height.equalTo(46)
        }
        descriptionImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        descriptionStackView.snp.makeConstraints {
            $0.leading.equalTo(segmentedControl).offset(2)
            $0.top.equalTo(segmentedControl.snp.bottom).offset(6)
            $0.height.equalTo(19)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        view.backgroundColor = .appColor(.newBackground)
        setUpLayouts()
        setUpConstraints()
    }
}

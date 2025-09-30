//
//  OrderCartViewController.swift
//  koin
//
//  Created by 홍기정 on 9/25/25.
//

import UIKit
import Combine

final class OrderCartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OrderCartViewModel
    private let inputSubject = PassthroughSubject<OrderCartViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Components
    private let emptyView = EmptyView()
    private let tableView = OrderCartTableView().then {
        $0.sectionHeaderTopPadding = 0
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.sectionFooterHeight = .zero
    }
    private let bottomSheet = OrderCartBottomSheet()
    
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
        bind()
        inputSubject.send(.viewDidLoad)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRightBarButton()
        configureNavigationBar(style: .order)
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject).sink { [weak self] output in
            switch output {
            case .updateCart(let cart):
                print(cart.items)
                self?.tableView.configure(cart: cart)
                self?.bottomSheet.configure(shopMinimumOrderAmount: cart.shopMinimumOrderAmount, totalAmount: cart.totalAmount, finalPaymentAmount: cart.finalPaymentAmount, itemsCount: cart.items.count)
            }
        }
        .store(in: &subscriptions)
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
        [emptyView, tableView, bottomSheet].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        bottomSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIApplication.hasHomeButton() ? 72 : 106)
        }
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomSheet.snp.top)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .appColor(.newBackground)
        setUpLayouts()
        setUpConstraints()
    }
}

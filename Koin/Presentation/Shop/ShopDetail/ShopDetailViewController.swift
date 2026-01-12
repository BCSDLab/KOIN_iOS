//
//  ShopDetailViewController.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit
import Combine

final class ShopDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let inputSubject = PassthroughSubject<ShopDetailViewModel.Input, Never>()
    
    // MARK: - UI Components
    private let shopDetailTableView: ShopDetailTableView = ShopDetailTableView().then {
        $0.separatorStyle = .none
        $0.allowsSelection = false
    }
    
    // MARK: - Initailizer
    init(viewModel: ShopDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(style: .empty)
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
        title = "가게정보"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shopDetailTableView.scrollToHighlightedCell()
    }

    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case .update(let shopDetail):
                self.shopDetailTableView.configure(shopDetail: shopDetail,
                                                   shouldHighlight: self.viewModel.shouldHighlight)
            }
        }
        .store(in: &subscriptions)
    }
}

extension ShopDetailViewController {
    
    private func setUpLayouts() {
        [shopDetailTableView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        shopDetailTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

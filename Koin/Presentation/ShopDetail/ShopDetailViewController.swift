//
//  ShopDetailViewController.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import UIKit
import Combine

class ShopDetailViewController: UIViewController {
    
    // MARK: - Properties
    let viewModel: ShopDetailViewModel
    private let inputSubject = PassthroughSubject<ShopDetailViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let shopId: Int?
    private let isFromOrder: Bool
    
    // MARK: - Initializer
    init(viewModel: ShopDetailViewModel, shopId: Int?, isFromOrder: Bool) {
        self.viewModel = viewModel
        self.shopId = shopId
        self.isFromOrder = isFromOrder
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        bind()
    }
}

extension ShopDetailViewController {
    
    // MARK: - Function
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.sink { output in
            switch output {
            case .someOutput: return
            }
        }
        .store(in: &subscriptions)
    }
}



//
//  OrderCartViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit

final class OrderCartViewController: UIViewController {
    
    // MARK: - UI Components

    
    // MARK: - Initialization
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    private func bind() {

    }
}

extension OrderCartViewController {
    
    private func setUpLayOuts() {
    }
    
    private func setUpConstraints() {

    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .purple
    }
}


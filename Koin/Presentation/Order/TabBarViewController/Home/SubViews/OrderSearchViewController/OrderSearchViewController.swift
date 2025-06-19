//
//  OrderSearchViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit

final class OrderSearchViewController: UIViewController {
    
    // MARK: - UI Components

    
    // MARK: - Initialization
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "검색"
        configureView()
    }
    
    // MARK: - Bind
    private func bind() {

    }
}

extension OrderSearchViewController {
    
    private func setUpLayOuts() {
    }
    
    private func setUpConstraints() {

    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = .blue
//        view.backgroundColor = UIColor.appColor(.newBackground)

    }
}


//
//  OrderViewController.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit
import SnapKit

final class OrderViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView().then { _ in
    }
    
    private let searchBarButton = UIButton(type: .system).then { button in
        var config = UIButton.Configuration.plain()
        
        if let base = UIImage.appImage(asset: .search){
            let sized = base.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)
            )
            config.image = sized.withTintColor(
                .appColor(.neutral500),
                renderingMode: .alwaysTemplate
            )
        }
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        var titleAttribute = AttributedString("검색어를 입력해주세요.")
        titleAttribute.font = UIFont.appFont(.pretendardRegular, size: 14)
        titleAttribute.foregroundColor = UIColor.appColor(.neutral400)
        config.attributedTitle = titleAttribute
        
        config.background.backgroundColor = .white
        config.background.cornerRadius = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16,
                                                       bottom: 0, trailing: 160)
        
        button.configuration = config
        button.tintColor = .appColor(.neutral500)
        
        button.layer.shadowColor   = UIColor.black.cgColor
        button.layer.shadowOffset  = CGSize(width: 0, height: 2)
        button.layer.shadowRadius  = 4
        button.layer.shadowOpacity = 0.04
        button.layer.masksToBounds = false
    }


    
    // MARK: - Initialization
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
    }
    
    // MARK: - Bind
    private func bind() {

    }
    
    private func setAddTarget() {
        searchBarButton.addTarget(self, action: #selector(searchBarButtonTapped), for: .touchUpInside)
    }
}

extension OrderViewController {
    @objc private func searchBarButtonTapped() {
        let searchVC = OrderSearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension OrderViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        
        [searchBarButton].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom).offset(-100)
        }
        
        searchBarButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = UIColor.appColor(.newBackground)
    }
}


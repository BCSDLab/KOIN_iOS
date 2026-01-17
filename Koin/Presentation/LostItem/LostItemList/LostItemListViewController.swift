//
//  LostItemListViewController.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit

final class LostItemListViewController: UIViewController {
    
    // MARK: - UI Components
    private let filterButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("필터", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardBold, size: 14),
            .foregroundColor: UIColor.appColor(.neutral600)
        ]))
        configuration.image = .appImage(asset: .filter)?.withTintColor(.appColor(.primary600), renderingMode: .alwaysTemplate).resize(to: CGSize(width: 20, height: 20))
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        configuration.imagePlacement = .trailing
        $0.configuration = configuration
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
        $0.layer.masksToBounds = false
        $0.backgroundColor = .appColor(.info200)
    }
    private let lostItemListTableView = LostItemListTableView()
    private let writeButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .pencil)?.withTintColor(.appColor(.neutral600), renderingMode: .alwaysTemplate).resize(to: CGSize(width: 24, height: 24))
        configuration.attributedTitle = AttributedString("글쓰기", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.neutral600)
        ]))
        configuration.imagePadding = 4
        configuration.imagePlacement = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        $0.configuration = configuration
        $0.backgroundColor = .appColor(.neutral50)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 21
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(style: .empty)
        configureRightBarButton()
        configureView()
        title = "분실물"
    }
}

extension LostItemListViewController {
    
    private func configureRightBarButton() {
        //let searchButton = UIBarButtonItem(image: .appImage(asset: .search), style: <#T##UIBarButtonItem.Style#>, target: <#T##Any?#>, action: <#T##Selector?#>)
        let rightBarButton = UIBarButtonItem(image: .appImage(symbol: .magnifyingGlass), style: .plain, target: self, action: #selector(searchButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButton
        
    }
    @objc private func searchButtonTapped() {
        
    }
}

extension LostItemListViewController {
    
    private func setLayouts() {
        [lostItemListTableView, filterButton, writeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        filterButton.snp.makeConstraints {
            $0.width.equalTo(73)
            $0.height.equalTo(34)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
        }
        lostItemListTableView.snp.makeConstraints {
            $0.top.equalTo(filterButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        writeButton.snp.makeConstraints {
            $0.width.equalTo(94)
            $0.height.equalTo(42)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    private func configureView() {
        setLayouts()
        setConstraints()
        view.backgroundColor = .appColor(.neutral0)
    }
}

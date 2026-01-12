//
//  ShopSearchViewController.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import UIKit
import Combine

final class ShopSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopSearchViewModel
    private let inputSubject = PassthroughSubject<ShopSearchViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    weak var coordinator: ShopCoordinator?
    
    // MARK: - UI Components
    private let navigationBackgroundView = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
    }
    private let backgroundView = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
    }
    private let searchTextField = UITextField().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        
        let placeholder = NSAttributedString(
            string: "검색어를 입력해주세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral500)
            ]
        )
        $0.attributedPlaceholder = placeholder
        
        let leftImageView = UIImageView(image: .appImage(asset: .search))
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 40))
        leftImageView.contentMode = .center
        leftImageView.center = CGPoint(x: 24, y: 20)
        leftContainer.addSubview(leftImageView)
        $0.leftView = leftContainer
        $0.leftViewMode = .always
        
        $0.clearButtonMode = .whileEditing
        
        $0.contentHorizontalAlignment = .leading
        
        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius  = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
    }
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.8)
    }
    
    private let shopSearchTableView = ShopSearchTableView().then {
        $0.backgroundColor = .appColor(.newBackground)
        $0.isHidden = true
        $0.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        $0.clipsToBounds = false
    }
    
    // MARK: - Initializer
    init(viewModel: ShopSearchViewModel) {
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
        navigationItem.title = "검색"
        bind()
        setAddTarget()
        setDelegate()
        searchTextField.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .transparentBlack)
    }
    
    // MARK: Bind
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .update(let shopSearch):
                self.updateTableView(shopSearch: shopSearch)
            }
        }.store(in: &subscriptions)
        
        shopSearchTableView.didTapCellPublisher.sink { [weak self] (shopId, shopName) in
            self?.viewModel.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.shopCategoriesSearchClick, category: .click, value: shopName)
            self?.navigateTo(shopId: shopId, shopName: shopName)
        }.store(in: &subscriptions)
        
        shopSearchTableView.didScrollPublisher.sink { [weak self] in
            guard self?.shopSearchTableView.isHidden == false else { return } // 화면 진입시 키보드 사라짐 방지
            self?.dismissKeyboard()
        }.store(in: &subscriptions)
    }
}
    
extension ShopSearchViewController {
    
    private func setAddTarget() {
        searchTextField.addTarget(self, action: #selector(keywordDidChange(_:)), for: .editingChanged)
        searchTextField.addTarget(self, action: #selector(searchDidBegin(_:)), for: .editingDidBegin)
    }
    private func setDelegate() {
        searchTextField.delegate = self
    }
}

// MARK: - @objc
extension ShopSearchViewController {
    
    @objc private func searchDidBegin(_ textField: UITextField) {
        let currentCategoryName = viewModel.selectedCategoryName
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCategoriesSearch, .click, "search in \(currentCategoryName)"))
    }

    @objc private func keywordDidChange(_ sender: UITextField) {
        guard let text = searchTextField.text else { return }
        if text == "" {
            dimView.isHidden = false
            shopSearchTableView.isHidden = true
        }
        else {
            inputSubject.send(.keywordDidChange(text))
        }
    }
}

extension ShopSearchViewController {
    
    private func updateTableView(shopSearch: ShopSearch) {
        dimView.isHidden = true
        shopSearchTableView.isHidden = false
        shopSearchTableView.configure(shopSearch: shopSearch)
    }
}

extension ShopSearchViewController {
    
    private func navigateTo(shopId: Int, shopName: String) {
        coordinator?.pushShopSummaryViewController(
            shopId: shopId,
            shopName: shopName,
            categoryName: viewModel.selectedCategoryName
        )
    }
}

extension ShopSearchViewController {
    
    private func setUpLayouts() {
        [navigationBackgroundView, dimView, shopSearchTableView, backgroundView, searchTextField].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        navigationBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIApplication.topSafeAreaHeight() + (navigationController?.navigationBar.frame.height ?? 0))
        }
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
        dimView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        shopSearchTableView.snp.makeConstraints {
            $0.top.bottom.equalTo(dimView)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        backgroundView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(dimView.snp.top)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .appColor(.newBackground)
    }
}

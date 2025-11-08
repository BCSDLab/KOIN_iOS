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
    
    // MARK: - UI Components
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
        configureNavigationBar(style: .order)
        navigationItem.title = "검색"
        bind()
        setAddTarget()
        setDelegate()
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
    }
}

extension ShopSearchViewController {
    
    private func setAddTarget() {
        searchTextField.addTarget(self, action: #selector(keywordDidChange(_:)), for: .editingChanged)
    }
    private func setDelegate() {
        searchTextField.delegate = self
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
    
    private func navigateTo(shopId: Int) {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchOrderShopSummaryFromShopUseCase = DefaultFetchOrderShopSummaryFromShopUseCase(repository: shopRepository)
        let fetchOrderShopMenusGroupsFromShopUseCase = DefaultFetchOrderShopMenusGroupsFromShopUseCase(repository: shopRepository)
        let fetchOrderShopMenusFromShopUseCase = DefaultFetchOrderShopMenusFromShopUseCase(shopRepository: shopRepository)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: shopRepository)
        // TODO: Merge 이후에 ViewModel 생성자 수정하기
        let viewModel = ShopSummaryViewModel(fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
                                             fetchOrderShopMenusGroupsFromShopUseCase: fetchOrderShopMenusGroupsFromShopUseCase,
                                             fetchOrderShopMenusFromShopUseCase: fetchOrderShopMenusFromShopUseCase,
                                             fetchShopDataUseCase: fetchShopDataUseCase,
                                             shopId: shopId)
        let viewController = ShopSummaryViewController(viewModel: viewModel, isFromOrder: false, orderableShopId: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ShopSearchViewController {
    
    private func setUpLayouts() {
        [searchTextField, dimView, shopSearchTableView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
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
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .appColor(.newBackground)
    }
}

//
//  OrderSearchViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import Combine
import SnapKit

final class OrderSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OrderHomeViewModel
    private let inputSubject: PassthroughSubject<OrderHomeViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - UI Components
    private let searchTextField = UITextField().then {
        let placeholder = NSAttributedString(
            string: "검색어를 입력해주세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral400)
            ]
        )
        $0.attributedPlaceholder = placeholder

        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12

        let icon = UIImage.appImage(asset: .search)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 8, weight: .regular))
            .withRenderingMode(.alwaysTemplate)
        let leftImageView = UIImageView(image: icon)
        leftImageView.contentMode = .center
        leftImageView.tintColor = .appColor(.neutral500)
        leftImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 40))
        leftImageView.center = CGPoint(x: 16, y: 20)
        leftContainer.addSubview(leftImageView)
        $0.leftView = leftContainer
        $0.leftViewMode = .always

        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        $0.rightView = rightContainer
        $0.rightViewMode = .always

        $0.clearButtonMode = .whileEditing

        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius  = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
    }
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.8)
    }
    
    private let searchedOrderShopCollectionView: RelatedShopCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 32
        let collectionView = RelatedShopCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        flowLayout.itemSize = CGSize(width: cellWidth, height: 48)
        flowLayout.minimumLineSpacing = 0
        collectionView.isScrollEnabled = false
        collectionView.isHidden = true
        return collectionView
    }()
    
    // MARK: - Initialization
    init(viewModel: OrderHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "검색"
        configureView()
        bind()
        setAddTarget()
        setDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }

    
    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .showSearchedResult(let keywords):
                    self.searchedOrderShopCollectionView.updateShop(keywords: keywords)
                default:
                    break
                }
            }
            .store(in: &subscriptions)
    }

    private func setAddTarget() {
    }
    
    private func setDelegate() {
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
    }
}

extension OrderSearchViewController {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        searchedOrderShopCollectionView.isHidden = false
        dimView.isHidden = true
        inputSubject.send(.searchTextChanged(text))
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cartButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension OrderSearchViewController {
    
    private func setUpLayOuts() {
        [searchTextField,
         dimView,
         searchedOrderShopCollectionView].forEach {
            view.addSubview($0)
        }

    }
    
    private func setUpConstraints() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
        
        dimView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        searchedOrderShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(image: UIImage.appImage(asset: .arrowBack)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupRightButton() {
        let cartButton = UIBarButtonItem(image: UIImage.appImage(asset: .shoppingCart)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(cartButtonTapped))
        cartButton.tintColor = .black
        navigationItem.rightBarButtonItem = cartButton
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setupBackButton()
        setupRightButton()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}


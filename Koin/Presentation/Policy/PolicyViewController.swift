//
//  PolicyViewController.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine
import UIKit

final class PolicyViewController: UIViewController {
    
    // MARK: - Properties
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then { scrollView in
    }
    
    private let policyTypeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let policyListTableView = PolicyListTableView().then { tableView in
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral800)
    }
    
    private let policyContentCollectionView = PolicyContentCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then { collectionView in
    }

    
    // MARK: - Initialization
    
    init(policyType: PolicyType) {
        super.init(nibName: nil, bundle: nil)
        policyListTableView.setUpPolicyList(type: policyType)
        policyContentCollectionView.setUpPolicyList(type: policyType)
        navigationItem.title = policyType.navigationTitle
        policyTypeLabel.text = policyType.displayName
        print(policyContentCollectionView.calculateDynamicHeight())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    private func bind() {
        
    }
}

extension PolicyViewController {
    
}

extension PolicyViewController {
    
   
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(policyListTableView)
      ///  view.addSubview(policyContentCollectionView)
        [policyTypeLabel, separateView, policyContentCollectionView].forEach {
            scrollView.addSubview($0)
        }
       
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(3000)
        }
        policyTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        policyListTableView.snp.makeConstraints { make in
            make.top.equalTo(policyTypeLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(policyListTableView.calculateDynamicHeight())
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(policyListTableView.snp.bottom).offset(28)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(1)
        }
        policyContentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(444)
   //         make.bottom.equalTo(scrollView.snp.bottom)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

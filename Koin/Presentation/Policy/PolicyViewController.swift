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
    
    private let scrollTopButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .topCircle), for: .normal)
    }
    // MARK: - Initialization
    
    init(policyType: PolicyType) {
        super.init(nibName: nil, bundle: nil)
        policyListTableView.setUpPolicyList(type: policyType)
        policyContentCollectionView.setUpPolicyList(type: policyType)
        navigationItem.title = policyType.navigationTitle
        policyTypeLabel.text = policyType.displayName
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
        scrollTopButton.addTarget(self, action: #selector(scrollTopButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        policyListTableView.selectedCellPublisher.sink { [weak self] cellIndex in
            self?.scrollToCell(at: cellIndex)
        }.store(in: &subscriptions)
    }
}

extension PolicyViewController {
    private func scrollToCell(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        if let cellAttributes = policyContentCollectionView.layoutAttributesForItem(at: indexPath) {
            let cellFrame = cellAttributes.frame
            let cellYPosition = cellFrame.origin.y
            scrollView.setContentOffset(CGPoint(x: 0, y: policyTypeLabel.frame.size.height + policyListTableView.calculateDynamicHeight() + 28 + separateView.frame.size.height + cellYPosition), animated: true)
        }
    }
    
    @objc private func scrollTopButtonTapped() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -100), animated: true)
    }
}

extension PolicyViewController {
    
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(scrollTopButton)
        [policyTypeLabel, separateView, policyContentCollectionView, policyListTableView, policyContentCollectionView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        policyTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(20)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        policyListTableView.snp.makeConstraints { make in
            make.top.equalTo(policyTypeLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(policyListTableView.calculateDynamicHeight())
            make.width.equalTo(view.snp.width)
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
            make.height.equalTo(1)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-20)
        }
        policyContentCollectionView.snp.updateConstraints { make in
            make.height.equalTo(policyContentCollectionView.calculateDynamicHeight())
        }
        scrollTopButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.bottom.equalTo(view.snp.bottom).offset(-37)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

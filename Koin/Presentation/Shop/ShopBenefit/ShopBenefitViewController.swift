//
//  ShopBenefitViewController.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class ShopBenefitViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSubject = PassthroughSubject<ShopBenefitViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: ShopBenefitViewModel
    private var didSwipeToPop = false
    
    // MARK: - UI Components
    private let benefitsTableView = ShopBenefitTableView()
    private let emptyView = ShopBenefitEmptyView().then {
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    init(viewModel: ShopBenefitViewModel, title: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(style: .empty)
        bind()
        inputSubject.send(.fetchEvents)
        configureView()
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .updateEvents(let events):
                updateEvents(events)
            }
        }.store(in: &subscriptions)
        
        benefitsTableView.imageTapPublisher.sink { [weak self] (imageUrls, indexPath) in
            guard let self else { return }
            let zoomedImageViewController = ZoomedImageViewControllerB()
            zoomedImageViewController.configure(urls: imageUrls, initialIndexPath: indexPath)
            zoomedImageViewController.modalTransitionStyle = .crossDissolve
            zoomedImageViewController.modalPresentationStyle = .fullScreen
            present(zoomedImageViewController, animated: true)
        }.store(in: &subscriptions)

        benefitsTableView.detailExpandedPublisher.sink { [weak self] in
            guard let self else { return }
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopBenefitDetail, EventParameter.EventCategory.click, self.viewModel.shopName))
        }.store(in: &subscriptions)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let didSwipeToPop = (navigationController as? CustomNavigationController)?.didSwipeToPop {
            self.didSwipeToPop = didSwipeToPop
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            let category: EventParameter.EventCategory = didSwipeToPop ? .swipe : .click
            
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopBenefitBack, category, viewModel.shopName))
        }
    }
}

extension ShopBenefitViewController {

    private func updateEvents(_ events: [ShopEvent]) {
        switch events.isEmpty {
        case true:
            benefitsTableView.isHidden = true
            emptyView.isHidden = false
        case false:
            benefitsTableView.configure(events: events)
            benefitsTableView.isHidden = false
            emptyView.isHidden = true
        }
    }
}

extension ShopBenefitViewController {
    
    private func configureView() {
        view.backgroundColor = .white
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [benefitsTableView, emptyView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        benefitsTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

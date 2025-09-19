//
//  OrderHistoryViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import SnapKit
import Combine

final class OrderHistoryViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: OrderHistoryViewModel
    private var cancellables = Set<AnyCancellable>()
    private let inputSubject = PassthroughSubject<OrderHistoryViewModel.Input, Never>()
    private var items: [OrderHistory] = []
    private let initialTab: Int
    private var currentQuery = OrderHistoryQuery(){
        didSet { render() }
    }
    
    private var emptyTopToSeparator: Constraint!
    private var emptyTopToList: Constraint!
    private var barTrailingToSuperview: Constraint!
    private var barTrailingToCancel: Constraint!
    
    private var appliedQuery: String = ""
    private var isSearching: Bool { !appliedQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var shadowAlpha: CGFloat = 0
    private var isRefreshingNow = false
    
    private let maxShadowAlpha: CGFloat = 0.6
    private let activationOffset: CGFloat = 1.5
    private let fadeDistance: CGFloat = 24.0
    
    
    init(viewModel: OrderHistoryViewModel, initialTab: Int = 0) {
        self.viewModel = viewModel
        self.initialTab = initialTab
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private let orderHistorySegment = UISegmentedControl().then {
        $0.insertSegment(withTitle: "지난 주문", at: 0, animated: true)
        $0.insertSegment(withTitle: "준비 중", at: 1, animated: true)
        $0.selectedSegmentIndex = 0
        
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.neutral500),
            .font: UIFont.appFont(.pretendardBold, size: 16)
        ], for: .normal)
        
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.new500),
            .font: UIFont.appFont(.pretendardBold, size: 16),
        ], for: .selected)
        
        $0.selectedSegmentTintColor = .clear
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.setDividerImage(UIImage(),
                           forLeftSegmentState: .normal,
                           rightSegmentState: .normal,
                           barMetrics: .default)
    }

    private let orderHistorySeperateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral400)
    }

    private let refreshControl = UIRefreshControl()

    private let orderHistoryUnderLineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.new500)
    }

    private let orderHistoryCollectionView = OrderHistoryCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    private let orderPrepareCollectionView = OrderPrepareCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        if let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
        }
    }

    //MARK: - emptyState UI

    private let emptyStateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.newBackground)
    }

    private let symbolImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .sleepBcsdSymbol)
    }

    private let noOrderHistoryLabel = UILabel().then {
        $0.text = "주문 내역이 없어요"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
        $0.textAlignment = .center
    }

    private let seeOrderHistoryButton = UIButton(
        configuration: {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString("과거 주문 내역 보기", attributes: .init([
                .font: UIFont.appFont(.pretendardBold, size: 13)
            ]))
            config.baseForegroundColor = UIColor.appColor(.neutral500)

            var background = UIBackgroundConfiguration.clear()
            background.cornerRadius = 8
            background.backgroundColor = UIColor.appColor(.neutral0)
            config.background = background

            config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            return config
        }()
    ).then {
        $0.layer.masksToBounds = false
        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius  = 4
    }

    private let topShadowView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.alpha = 0
    }

    private let searchBar = OrderHistoryCustomSearchBar()

    private lazy var searchDimView = UIControl().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0)
        $0.isHidden = false
    }

    private let searchCancelButton = UIButton(
        configuration: {
            var config = UIButton.Configuration.plain()

            var title = AttributedString("취소")
            title.font = UIFont.appFont(.pretendardBold, size: 14)
            title.foregroundColor = UIColor.appColor(.neutral500)
            config.attributedTitle = title

            config.baseForegroundColor = UIColor.appColor(.neutral500)
            config.contentInsets = .zero
            return config
        }()
    ).then {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let filterButtonRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 8
    }

    private let periodButton = FilteringButton().then {
        $0.set(title: "조회 기간", showsChevron: true)
        $0.setSelectable(false)
        $0.applyFilter(false)
    }

    private let stateInfoButton = FilteringButton().then {
        $0.set(title: "주문 상태 · 정보", showsChevron: true)
        $0.setSelectable(false)
        $0.applyFilter(false)
    }

    private let resetButton = FilteringButton().then {
        let icon = UIImage.appImage(asset: .refresh)
        $0.set(title: "초기화", iconRight: icon, showsChevron: false)
        $0.setSelectable(false)
        $0.applyFilter(false)
        $0.isHidden = true
        $0.alpha = 0
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
        setAddTarget()
        render()
        updateEmptyState()
        setupRefreshControl()
        

        orderHistorySegment.selectedSegmentIndex = initialTab
        changeSegmentLine(orderHistorySegment)
        
        orderPrepareCollectionView.onLoadedIDs = { ids in
            print("상점 id:", ids)
        }
        
        orderHistoryCollectionView.onReachEnd = { [weak self] in
            self?.inputSubject.send(.loadNextPage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.bringSubviewToFront(topShadowView)

        topShadowView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0,
                                 y: 0,
                                 width: topShadowView.bounds.width,
                                 height: 1)
        topBorder.backgroundColor = UIColor.black.withAlphaComponent(0.08).cgColor
        topShadowView.layer.addSublayer(topBorder)

        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0,
                                    y: topShadowView.bounds.height - 1,
                                    width: topShadowView.bounds.width,
                                    height: 1)
        bottomBorder.backgroundColor = UIColor.black.withAlphaComponent(0.08).cgColor
        topShadowView.layer.addSublayer(bottomBorder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.layoutIfNeeded()
        inputSubject.send(.refresh)
    }

    // MARK: - Bind
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .updateOrders(let newItems):
                    self.items = newItems
                    self.orderHistoryCollectionView.update(newItems)
                    self.updateEmptyState()
                    self.updateTopShadow()
                    self.endRefreshIfNeeded()
                    
                case .updatePreparing(let newItems):
                    self.orderPrepareCollectionView.update(newItems)
                    
                case .showEmpty(let isEmpty):
                    self.emptyStateView.isHidden = !isEmpty
                    self.orderHistoryCollectionView.isHidden = isEmpty
                    self.endRefreshIfNeeded()

                case .errorOccurred(let error):
                    print(error)

                case .endRefreshing:
                    self.endRefreshIfNeeded()
                    
                    
                case .navigateToOrderDetail:
                    break
                    
                case .appendOrders(let pageItems):
                    self.items.append(contentsOf: pageItems)
                    self.orderHistoryCollectionView.append(pageItems)
                }
            }
            .store(in: &cancellables)
        searchBar.onReturn = { [weak self] text in
            guard let self = self else { return }
                let trimmedQuery = text.trimmingCharacters(in: .whitespacesAndNewlines)
                self.appliedQuery = trimmedQuery
                self.inputSubject.send(.search(trimmedQuery))

                self.orderHistoryCollectionView.setContentOffset(.zero, animated: false)
                self.shadowAlpha = 0
                self.topShadowView.alpha = 0
                self.topShadowView.isHidden = true
                self.deactivateDimOnly()
                self.updateEmptyState()
        }
        
        updateSearchVisibility()
    }
    
    private func setAddTarget() {
        orderHistorySegment.addTarget(self, action: #selector(changeSegmentLine(_:)), for: .valueChanged)
        
        [periodButton, stateInfoButton].forEach {
            $0.addTarget(self, action: #selector(showFilterSheet), for: .touchUpInside)
        }
        
        resetButton.addTarget(self, action: #selector(resetFilterTapped), for: .touchUpInside)
        searchDimView.addTarget(self, action: #selector(dismissSearchOverlay), for: .touchUpInside)
        searchBar.textField.addTarget(self, action: #selector(searchTapped(_:)), for: .editingDidBegin)
        searchCancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        seeOrderHistoryButton.addTarget(self, action: #selector(seeOrderHistoryButtonTapped), for: .touchUpInside)
        
        orderPrepareCollectionView.onTapOrderDetailButton = { [weak self] paymentId in
            self?.presentOrderResultModal(with: paymentId)
        }

        orderHistoryCollectionView.onTapOrderInfoButton = { [weak self] paymentId in
            self?.presentOrderResultModal(with: paymentId)
        }
    }
    
    func setInitialTab(_ idx: Int) {
        orderHistorySegment.selectedSegmentIndex = idx
        changeSegmentLine(orderHistorySegment)
        DispatchQueue.main.async { [weak self] in
            self?.inputSubject.send(.refresh)
        }
    }
    
    private func deactivateDimOnly() {
        barTrailingToSuperview.deactivate()
        barTrailingToCancel?.activate()
        searchCancelButton.isHidden = false
        searchCancelButton.alpha = 1

        searchBar.unfocus()
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            self.searchDimView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchDimView.isHidden = true
        }
    }

    private func presentOrderResultModal(with paymentId: Int) {
        guard let url = URL(string: "https://order.stage.koreatech.in/result/\(paymentId)") else { return }
        let viewController = OrderResultWebViewController(resultURL: url)
        viewController.modalPresentationStyle = .overFullScreen
        definesPresentationContext = true
        present(viewController, animated: true)
    }
}

extension OrderHistoryViewController {
    
    private func setUpLayOuts() {
        [orderHistorySegment, orderHistorySeperateView, orderHistoryUnderLineView, filterButtonRow, searchBar, searchCancelButton, searchDimView,orderHistoryCollectionView,orderPrepareCollectionView, emptyStateView, topShadowView].forEach {
            view.addSubview($0)
        }
        
        emptyStateView.isHidden = true
        
        [symbolImageView , noOrderHistoryLabel, seeOrderHistoryButton].forEach{
            emptyStateView.addSubview($0)
        }
        
        [resetButton, periodButton, stateInfoButton].forEach {
            filterButtonRow.addArrangedSubview($0)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.snp.makeConstraints { $0.height.equalTo(34) }
        }

    }
    
    private func setUpConstraints() {
        orderHistorySegment.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        orderHistorySeperateView.snp.makeConstraints {
            $0.bottom.equalTo(orderHistorySegment.snp.bottom)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(1)
        }
        
        orderHistoryUnderLineView.snp.makeConstraints {
            $0.bottom.equalTo(orderHistorySegment.snp.bottom)
            $0.width.equalTo((UIScreen.main.bounds.width/2) - 15)
            $0.height.equalTo(2)
            $0.leading.equalTo(orderHistorySegment.snp.leading).offset(7.5)
        }
        
        filterButtonRow.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
            $0.height.equalTo(34)
        }
        
        searchBar.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(orderHistorySeperateView.snp.bottom).offset(16)
            $0.height.equalTo(40)
            barTrailingToSuperview = $0.trailing.equalToSuperview().inset(16).constraint
        }
        
        barTrailingToCancel = searchBar.snp.prepareConstraints {
            $0.trailing.equalToSuperview().inset(57.5)
        }.first
        
        searchCancelButton.isHidden = true
        searchCancelButton.alpha = 0
        searchCancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.leading.equalTo(searchBar.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(searchBar.snp.height)
        }
        
        searchDimView.snp.makeConstraints {
            $0.top.equalTo(filterButtonRow.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        self.barTrailingToSuperview.activate()
        self.barTrailingToCancel?.deactivate()
        
        
        orderHistoryCollectionView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(filterButtonRow.snp.bottom).offset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            
        }
        
        orderPrepareCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(orderHistorySeperateView.snp.bottom).offset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
        
        emptyStateView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            emptyTopToSeparator = emptyStateView.snp.prepareConstraints {
                $0.top.equalTo(orderHistorySeperateView.snp.bottom)
            }.first

            emptyTopToList = emptyStateView.snp.prepareConstraints {
                $0.top.equalTo(orderHistoryCollectionView.snp.top)
            }.first

        }
        
        
        symbolImageView.snp.makeConstraints {
            $0.centerX.equalTo(self.view)
            $0.centerY.equalTo(self.view)
            $0.width.equalTo(95)
            $0.height.equalTo(75)
        }
        
        noOrderHistoryLabel.snp.makeConstraints{
            $0.top.equalTo(symbolImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(204)
        }
        
        seeOrderHistoryButton.snp.makeConstraints {
            $0.top.equalTo(noOrderHistoryLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(35)
        }
        
        topShadowView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(filterButtonRow.snp.bottom).offset(12)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = UIColor.appColor(.newBackground)
        orderHistoryCollectionView.alwaysBounceVertical = true
        orderPrepareCollectionView.alwaysBounceVertical = true
        orderHistoryCollectionView.onDidScroll = {[weak self] y in
            self?.updateTopShadow(using: y)
        }
    }
}

extension OrderHistoryViewController{
    private func render() {
        periodButton.setTitle(currentQuery.periodTitle)
        periodButton.applyFilter(currentQuery.period != .none)

        stateInfoButton.setTitle(currentQuery.infoTitle)
        let hasInfo = (currentQuery.type != .none) || (currentQuery.status != .none)
        stateInfoButton.applyFilter(hasInfo)


        updateResetVisibility()
        if orderHistorySegment.selectedSegmentIndex == 0 {
            inputSubject.send(.applyQuery(currentQuery))
        } else {
            orderPrepareCollectionView.reloadData()
        }
        updateEmptyState()
        updateTopShadow()
    }
    
    private func updateResetVisibility() {
        let show = (currentQuery.period != .none) || (currentQuery.type != .none) || (currentQuery.status != .none)
        if show {
            resetButton.isHidden = false
            UIView.animate(withDuration: 0.18) { self.resetButton.alpha = 1 }
        } else {
            UIView.animate(withDuration: 0.18, animations: {
                self.resetButton.alpha = 0
            }) { _ in
                self.resetButton.isHidden = true
            }
        }
    }

    private func updateSearchVisibility() {
        let isHistory = (orderHistorySegment.selectedSegmentIndex == 0)

        searchBar.isHidden = !isHistory
        searchCancelButton.isHidden = !isHistory
        filterButtonRow.isHidden = !isHistory
        orderHistoryCollectionView.isHidden = !isHistory
        orderPrepareCollectionView.isHidden = isHistory

        if isHistory {
            emptyTopToSeparator.deactivate()
            emptyTopToList.activate()
        } else {
            cancelButtonTapped()
            emptyTopToList.deactivate()
            emptyTopToSeparator.activate()
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        topShadowView.isHidden = !isHistory || !emptyStateView.isHidden
        topShadowView.alpha = 0
        
        updateTopShadow()
    }
    
    private func updateEmptyState() {
        let isHistoryTab     = (orderHistorySegment.selectedSegmentIndex == 0)
        let isEmptyHistory   = orderHistoryCollectionView.totalItemCount == 0
        let isEmptyPreparing = orderPrepareCollectionView.totalItemCount == 0
        let shouldShowEmpty  = isHistoryTab ? isEmptyHistory : isEmptyPreparing

        if isHistoryTab {
            if isEmptyHistory {
                if isSearching {
                    noOrderHistoryLabel.text = "검색 결과가 없어요"
                } else {
                    noOrderHistoryLabel.text = "주문 내역이 없어요"
                }
            }
            seeOrderHistoryButton.isHidden = true
        } else {
            if isEmptyPreparing {
                noOrderHistoryLabel.text = "준비 중인 음식이 없어요"
            }
            seeOrderHistoryButton.isHidden = false
        }
        
        if isHistoryTab {
            if isEmptyHistory {
                if isSearching {
                    searchBar.isHidden = false
                    filterButtonRow.isHidden = false
                    orderHistoryCollectionView.isHidden = false
                    emptyStateView.isHidden = false
                } else {
                    searchBar.isHidden = true
                    filterButtonRow.isHidden = true
                    orderHistoryCollectionView.isHidden = true
                    emptyStateView.isHidden = false
                    seeOrderHistoryButton.isHidden = true
                }
            } else {
                searchBar.isHidden = false
                filterButtonRow.isHidden = false
                orderHistoryCollectionView.isHidden = false
                emptyStateView.isHidden = true
                seeOrderHistoryButton.isHidden = true
            }
        } else {
            orderPrepareCollectionView.isHidden = shouldShowEmpty
            emptyStateView.isHidden = !shouldShowEmpty
            seeOrderHistoryButton.isHidden = false
        }

        if shouldShowEmpty {
            shadowAlpha = 0
            topShadowView.alpha = 0
            topShadowView.isHidden = true
        } else {
            updateTopShadow()
        }
    }

    
    private func setupRefreshControl() {
        orderHistoryCollectionView.refreshControl = refreshControl

        refreshControl.removeTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    private func endRefreshIfNeeded() {
        guard refreshControl.isRefreshing || isRefreshingNow else { return }
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.isRefreshingNow = false
        }
    }
}

// MARK: - @objc

extension OrderHistoryViewController {
    
    @objc private func changeSegmentLine(_ segment: UISegmentedControl){
        let segmentCount = CGFloat(segment.numberOfSegments)
        let leadingDistance: CGFloat = CGFloat(segment.selectedSegmentIndex) * (UIScreen.main.bounds.width / segmentCount) + 7.5
        
        UIView.animate(withDuration:0.2, animations: {
            self.orderHistoryUnderLineView.snp.updateConstraints {
                $0.leading.equalTo(self.orderHistorySegment.snp.leading).offset(leadingDistance)
            }
            self.updateSearchVisibility()
            self.updateEmptyState()
            self.view.layoutIfNeeded()
            self.updateTopShadow()
        })
    }
    
    @objc private func showFilterSheet(){
        guard presentedViewController == nil else {return}
        
        let sheet = FilterBottomSheetViewController(initialQuery: currentQuery)
        sheet.onApply = { [weak self] newQuery in
            guard let self = self else {return}
            self.currentQuery = newQuery
            self.inputSubject.send(.applyQuery(newQuery))
        }
        
        sheet.modalPresentationStyle = .overFullScreen
        present(sheet, animated: false)
    }
    
    @objc private func didPullToRefresh() {
        guard !isRefreshingNow else { return }
        isRefreshingNow = true
        inputSubject.send(.refresh)
    }
        
    @objc private func resetFilterTapped() {
        currentQuery.resetFilter()
        inputSubject.send(.applyQuery(currentQuery))
        
    }
    
    @objc private func searchTapped(_ sender: UITextField) {
        barTrailingToSuperview.deactivate()
        barTrailingToCancel?.activate()
        
        view.bringSubviewToFront(searchDimView)
        view.bringSubviewToFront(searchBar)
        view.bringSubviewToFront(searchCancelButton)

        searchCancelButton.isHidden = false
        searchDimView.isHidden = false
        searchBar.focus()
        
        searchBar.becomeFirstResponder()

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                self.searchCancelButton.alpha = 1
                self.searchDimView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func cancelButtonTapped() {
        searchBar.unfocus()
        searchBar.textField.text = ""
        appliedQuery = ""
        inputSubject.send(.search(""))
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            self.searchCancelButton.alpha = 0
            self.searchDimView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchCancelButton.isHidden = true
            self.searchDimView.isHidden = true
            self.barTrailingToCancel?.deactivate()
            self.barTrailingToSuperview.activate()
            self.updateTopShadow()
        }
    }
    
    @objc private func dismissSearchOverlay(){
        searchBar.unfocus()
        barTrailingToCancel?.deactivate()
        barTrailingToSuperview.activate()
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            self.searchCancelButton.alpha = 0
            self.searchDimView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchCancelButton.isHidden = true
            self.searchDimView.isHidden = true
        }
    }
    
    @objc private func seeOrderHistoryButtonTapped(){
        if orderHistorySegment.selectedSegmentIndex != 0 {
            orderHistorySegment.selectedSegmentIndex = 0
        }
        changeSegmentLine(orderHistorySegment)
        dismissSearchOverlay()
        inputSubject.send(.applyQuery(currentQuery))
    }
    
}

extension OrderHistoryViewController: UICollectionViewDelegate, UIScrollViewDelegate {
    
    //MARK: - ScrollSet
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === orderHistoryCollectionView else { return }
        updateTopShadow(using: scrollView.contentOffset.y)
    }
    
    private func updateTopShadow(using y: CGFloat? = nil, forceHide: Bool = false) {
        let isHistoryTab = (orderHistorySegment.selectedSegmentIndex == 0)
        let active = isHistoryTab && emptyStateView.isHidden && !forceHide

        guard active else {
            shadowAlpha = 0
            topShadowView.alpha = 0
            topShadowView.isHidden = true
            return
        }

        let yy = max(y ?? orderHistoryCollectionView.contentOffset.y, 0)
        guard yy > activationOffset else {
            shadowAlpha = 0
            topShadowView.alpha = 0
            topShadowView.isHidden = true
            return
        }
        
        let progress = min(yy / fadeDistance , 1.0)
        let target = progress * maxShadowAlpha
        
        if topShadowView.isHidden {
            topShadowView.isHidden = false
        }
        shadowAlpha += (target - shadowAlpha) * 0.20
        topShadowView.alpha = shadowAlpha
    }

}

private extension UICollectionView {
    var totalItemCount: Int {
        (0..<numberOfSections).reduce(0) { $0 + numberOfItems(inSection: $1) }
    }
}


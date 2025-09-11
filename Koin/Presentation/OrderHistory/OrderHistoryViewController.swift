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
    
    private let viewModel: OrderViewModel
    private var cancellables = Set<AnyCancellable>()
    private var items: [OrderViewModel.OrderItem] = []
    private let input = PassthroughSubject<OrderViewModel.Input, Never>()
    
    private var isSearching: Bool {
        !(searchBar.textField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private let initialTab: Int
    
    
    init(viewModel: OrderViewModel, initialTab: Int = 0) {
        self.viewModel = viewModel
        self.initialTab = initialTab
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    private var currentFilter: OrderFilter = .empty {
        didSet { render() }
    }
    private var topToSearch: Constraint!
    private var topToFilter: Constraint!
    private var barTrailingToSuperview: Constraint!
    private var barTrailingToCancel: Constraint!
    private var shadowTopToFilter: Constraint!
    private var shadowTopToSeparator: Constraint!
    
    private var shadowAlpha: CGFloat = 0

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
    ).then {
        if let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
        }
    }

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

    
    // MARK: - Initialization
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
        bindViewModel()
        setDelegate()
        render()
        updateSearchVisibility(animated: false)
        updateEmptyState()
        setupRefreshControl()

        orderHistorySegment.selectedSegmentIndex = initialTab
        changeSegmentLine(orderHistorySegment)
        
        orderPrepareCollectionView.onLoadedIDs = { ids in
            print("prepare loaded ids:", ids)
        }
        
        orderHistoryCollectionView.onReachEnd = { [weak self] in
            self?.input.send(.loadNextPage)
        }
        
        input.send(.viewDidLoad)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
    }
    

    // MARK: - Bind
    private func bind() {
        
        orderHistorySegment.addTarget(self, action: #selector(changeSegmentLine(_:)), for: .valueChanged)
        [periodButton, stateInfoButton].forEach {
            $0.addTarget(self, action: #selector(showFilterSheet), for: .touchUpInside)
        }
        
        resetButton.addTarget(self, action: #selector(resetFilterTapped), for: .touchUpInside)
        searchDimView.addTarget(self, action: #selector(dismissSearchOverlay), for: .touchUpInside)
        searchBar.textField.delegate = self
        searchBar.textField.addTarget(self, action: #selector(searchTapped(_:)), for: .editingDidBegin)
        searchCancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        seeOrderHistoryButton.addTarget(self, action: #selector(seeOrderHistoryButtonTapped), for: .touchUpInside)
        
        updateSearchVisibility(animated: false)
    }
    
    private func setDelegate(){
        searchBar.textField.delegate = self
        orderHistoryCollectionView.delegate = self
        orderPrepareCollectionView.delegate = self
        orderHistoryCollectionView.alwaysBounceVertical = true
        orderPrepareCollectionView.alwaysBounceVertical = true
        searchBar.onTextChanged = { [weak self] text in
            self?.input.send(.search(text))
        }
        
        searchBar.onReturn = { [weak self] text in
            self?.input.send(.search(text))
            self?.dismissSearchOverlay()
        }
        
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
            self.topToSearch = $0.top.equalTo(searchBar.snp.bottom).offset(16).constraint
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
            $0.height.equalTo(34)
        }
        
        self.topToFilter = filterButtonRow.snp.prepareConstraints{
            $0.top.equalTo(orderHistorySeperateView.snp.bottom).offset(16)
        }.first
                
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
            $0.bottom.equalToSuperview().offset(-12)
            
        }
        
        orderPrepareCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(orderHistorySeperateView.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        emptyStateView.snp.makeConstraints{
            $0.top.equalTo(orderHistorySeperateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
    }
}

extension OrderHistoryViewController{
    private func render() {
        if let period = currentFilter.period {
            switch period {
            case .threeMonths: periodButton.setTitle("최근 3개월")
            case .sixMonths: periodButton.setTitle("최근 6개월")
            case .oneYear: periodButton.setTitle("최근 1년")
            }
            periodButton.applyFilter(true)
        } else {
            periodButton.setTitle("조회 기간")
            periodButton.applyFilter(false)
        }
        
        var infoTitle = "주문 상태 · 정보"
        if let method = currentFilter.method {
            infoTitle = (method == .delivery ? "배달" : "포장")
        }
        if currentFilter.info.contains(.completed) {
            infoTitle += (infoTitle == "주문 상태 · 정보" ? "완료" : " · 완료")
        }
        if currentFilter.info.contains(.canceled) {
            infoTitle += (infoTitle == "주문 상태 · 정보" ? "취소" : " · 취소")
        }
        stateInfoButton.setTitle(infoTitle)
        stateInfoButton.applyFilter(infoTitle != "주문 상태 · 정보")
        
        updateResetVisibility()
        if orderHistorySegment.selectedSegmentIndex == 0 {
            input.send(.applyFilter(currentFilter))
        } else {
            orderPrepareCollectionView.reloadData()
        }
        updateEmptyState()
        refreshShadowForCurrentTab()
    }
    
    private func updateResetVisibility() {
        let show = (currentFilter != .empty)
        if show {
            resetButton.isHidden = false
            UIView.animate(withDuration: 0.18) {
                self.resetButton.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.18, animations: {
                self.resetButton.alpha = 0
            }) { _ in
                self.resetButton.isHidden = true
            }
        }
    }

    private func updateSearchVisibility(animated: Bool = true) {
        let isHistory = (orderHistorySegment.selectedSegmentIndex == 0)

        searchBar.isHidden = !isHistory
        searchCancelButton.isHidden = !isHistory
        filterButtonRow.isHidden = !isHistory
        orderHistoryCollectionView.isHidden = !isHistory
        orderPrepareCollectionView.isHidden = isHistory

        if isHistory {
            topToFilter?.deactivate()
            topToSearch.activate()
        
        } else {
            cancelButtonTapped()
            topToSearch.deactivate()
            topToFilter?.activate()
        }
        
        topShadowView.isHidden = !isHistory || !emptyStateView.isHidden
        topShadowView.alpha = 0
        
        refreshShadowForCurrentTab()
    }
    
    private func updateEmptyState() {
        let isHistoryTab   = (orderHistorySegment.selectedSegmentIndex == 0)
        let isEmptyHistory = orderHistoryCollectionView.totalItemCount == 0
        let isEmptyPreparing = orderPrepareCollectionView.totalItemCount == 0
        let shouldShowEmpty  = isHistoryTab ? isEmptyHistory : isEmptyPreparing

        noOrderHistoryLabel.text = isHistoryTab
            ? (isSearching ? "검색 결과가 없어요" : "주문 내역이 없어요")
            : "준비 중인 음식이 없어요"

        seeOrderHistoryButton.isHidden = isHistoryTab || !shouldShowEmpty || isSearching
        emptyStateView.isHidden = !shouldShowEmpty

        topShadowView.alpha = shouldShowEmpty ? 0 : topShadowView.alpha

        if isHistoryTab {
            searchBar.isHidden = shouldShowEmpty && !isSearching
            filterButtonRow.isHidden = shouldShowEmpty && !isSearching
            orderHistoryCollectionView.isHidden = shouldShowEmpty

            if shouldShowEmpty && !isSearching { cancelButtonTapped() }
        } else {
            orderPrepareCollectionView.isHidden = shouldShowEmpty
        }
    }

    
    private func setupRefreshControl() {
        orderHistoryCollectionView.alwaysBounceVertical = true
        orderHistoryCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
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
            self.updateSearchVisibility(animated: false)
            self.updateEmptyState()
            self.view.layoutIfNeeded()
            self.refreshShadowForCurrentTab()
        })
    }
    
    @objc private func showFilterSheet(){
        guard presentedViewController == nil else {return}
        
        let sheet = FilterBottomSheetViewController(initial: currentFilter)
        sheet.onApply = { [weak self] filter in
            self?.currentFilter = filter
            
        }
        
        sheet.modalPresentationStyle = .overFullScreen
        present(sheet, animated: false)
    }
    
    @objc private func didPullToRefresh() {
        input.send(.refresh)
    }
        
    @objc private func resetFilterTapped() {
        currentFilter = .empty
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
        input.send(.search(""))
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            self.searchCancelButton.alpha = 0
            self.searchDimView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchCancelButton.isHidden = true
            self.searchDimView.isHidden = true
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
        input.send(.applyFilter(currentFilter))
    }
    
}



extension OrderHistoryViewController: UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == searchBar.textField && searchCancelButton.isHidden {
            print("터치입력됨")
        }
        return true
    }
        
    //MARK: - ScrollSet
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if orderHistorySegment.selectedSegmentIndex == 0, scrollView == orderHistoryCollectionView {
            let y = scrollView.contentOffset.y
            let h = scrollView.contentSize.height
            let frameH = scrollView.frame.size.height
            if h > 0, y > h - frameH - 600 {
                input.send(.loadNextPage)
            }
        }
        
        let y = max(scrollView.contentOffset.y, 0)
        let target = min(y / 12.0, 1.0)
        setShadowAlphaSmooth(to: target)
    }
    
    private func refreshShadowForCurrentTab() {
        let isHistory = (orderHistorySegment.selectedSegmentIndex == 0)

        guard isHistory, emptyStateView.isHidden else {
            topShadowView.alpha = 0
            topShadowView.isHidden = true
            return
        }

        topShadowView.isHidden = false
        let y = max(orderHistoryCollectionView.contentOffset.y, 0)
        let target = min(y / 12.0, 1.0)
        setShadowAlphaSmooth(to: target)
    }
    
    private func setShadowAlphaSmooth(to target: CGFloat) {
        let t = min(max(target, 0), 1)
        shadowAlpha += (t - shadowAlpha) * 0.20
        topShadowView.alpha = shadowAlpha
    }
    
    //MARK: - CollectionView ItemSize
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == orderHistoryCollectionView{
            return CGSize(width: UIScreen.main.bounds.width - 48 , height: 286)
        } else if collectionView == orderPrepareCollectionView{
            return CGSize(width: UIScreen.main.bounds.width - 48 , height: 321)
        }
        return CGSize(width: 0, height: 0)
    }

}

private extension UICollectionView {
    var totalItemCount: Int {
        (0..<numberOfSections).reduce(0) { $0 + numberOfItems(inSection: $1) }
    }
}

extension OrderHistoryViewController {
    
    private func bindViewModel() {
        let output = viewModel.transform(with: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .updateOrders(let newItems):
                    self.items = newItems
                    self.orderHistoryCollectionView.update(newItems.map { $0.asCollectionItem })
                    self.updateEmptyState()
                case .updatePreparing(let newItems):
                    print("updatePreparing:", newItems.count)
                    self.orderPrepareCollectionView.update(newItems.map { $0.asCollectionItem })
                    
                case .showEmpty(let isEmpty):
                    self.emptyStateView.isHidden = !isEmpty
                    self.orderHistoryCollectionView.isHidden = isEmpty

                case .errorOccurred(let error):
                    print(error)

                case .endRefreshing:
                    self.refreshControl.endRefreshing()

                case .navigateToOrderDetail:
                    break
                case .appendOrders(let pageItems):
                    self.items.append(contentsOf: pageItems)
                    self.orderHistoryCollectionView.append(pageItems.map { $0.asCollectionItem })
                }
            }
            .store(in: &cancellables)
        input.send(.viewDidLoad)
    }


    
    private func bindCollectionViewCallbacks() {
        orderHistoryCollectionView.onSelect = { [weak self] orderId in
            self?.input.send(.selectOrder(orderId))
        }
        
        orderHistoryCollectionView.onTapReorder = { [weak self] orderId in
            self?.input.send(.tapReorder(orderId))
        }
    }
}


private extension OrderViewModel.OrderItem {
    var asCollectionItem: OrderHistoryCollectionView.Item {
        .init(
            id: id,
            stateText: stateText,
            dateText: dateText,
            storeName: storeName,
            menuName: menuName,
            priceText: priceText,
            imageURL: imageURL,
            canReorder: canReorder
        )
    }
}

private extension OrderViewModel.PreparingItem {
    var asCollectionItem: OrderPrepareCollectionView.Item {
        .init(
            id: id,
            methodText: methodText,
            estimatedTimeText: estimatedTimeText,
            explanationText: explanationText,
            imageURL: imageURL,
            storeName: storeName,
            menuName: menuName,
            priceText: priceText
        )
    }
    
}

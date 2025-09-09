//
//  OrderHistoryViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import SnapKit

final class OrderHistoryViewController: UIViewController {
    
    private var currentFilter: OrderFilter = .empty {
        didSet { render() }
    }
    
    private var topToSearch: Constraint!
    private var topToFilter: Constraint!
    private var barTrailingToSuperview: Constraint!
    private var barTrailingToCancel: Constraint!
    
    private var shadowAlpha: CGFloat = 0

    // MARK: - UI Components
    
    private let orderHistorySegment: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "지난 주문", at: 0, animated: true)
        segment.insertSegment(withTitle: "준비 중", at: 1, animated: true)
        segment.selectedSegmentIndex = 0 
        
        segment.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.neutral500),
            .font: UIFont.appFont(.pretendardBold, size: 16)
        ], for: .normal)
        
        segment.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.new500),
            .font: UIFont.appFont(.pretendardBold, size: 16),
        ], for: .selected)
        
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        return segment
    }()
    
    private let orderHistorySeperateView: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.neutral400)
        return view
    }()
    
    private let orderHistoryUnderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.new500)
        return view
    }()
    
    private let orderHistoryCollectionView: OrderHistoryCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return OrderHistoryCollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let orderPrepareCollectionView: OrderPrepareCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return OrderPrepareCollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    //MARK: - emptyState
    
    private let emptyStateView: UIView = {
        let v = UIView()
        v.backgroundColor = .appColor(.newBackground)
        return v
    }()
    
    private let symbolImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.appImage(asset: .emptyBcsdSymbolLogo)
        return iv
    }()
    
    private let ZzzImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.appImage(asset: .Zzz)
        return iv
    }()
    
    private let noOrderHistoryLabel: UILabel = {
        let l = UILabel()
        l.text = "주문 내역이 없어요"
        l.font = UIFont.appFont(.pretendardBold, size: 18)
        l.textColor = .appColor(.neutral500)
        l.textAlignment = .center
        return l
    }()
    
    private let seeOrderHistoryButton: UIButton = {
        var cf = UIButton.Configuration.plain()
        cf.attributedTitle = AttributedString("과거 주문 내역 보기", attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 13)
        ]))
        cf.baseForegroundColor = UIColor.appColor(.neutral500)
        var bg = UIBackgroundConfiguration.clear()
        bg.cornerRadius = 8
                
        bg.backgroundColor = UIColor.appColor(.neutral0)
        cf.background = bg
        
        cf.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)

        let b = UIButton(configuration: cf)
        
        b.layer.masksToBounds = false
        b.layer.shadowColor   = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.2
        b.layer.shadowOffset  = CGSize(width: 0, height: 2)
        b.layer.shadowRadius  = 4
        
        return b
    }()
    
    
    // MARK: - Shadow
    private let topShadowView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.alpha = 0
        return v
    }()

    private var shadowTopToFilter: Constraint!
    private var shadowTopToSeparator: Constraint!
    
    //MARK: - SearchBar
    
    private let searchBar: OrderHistoryCustomSearchBar = {
        let field = OrderHistoryCustomSearchBar()
        return field
    }()
    
    private lazy var searchDimView: UIControl = {
        let v = UIControl()
        v.backgroundColor = UIColor.black.withAlphaComponent(0)
        v.isHidden = false
        v.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return v
    }()
    
    private let searchCancelButton: UIButton = {
        var cf = UIButton.Configuration.plain()

        var title = AttributedString("취소")
        title.font = UIFont.appFont(.pretendardBold, size: 14)
        title.foregroundColor = UIColor.appColor(.neutral500)
        cf.attributedTitle = title

        cf.baseForegroundColor = UIColor.appColor(.neutral500)
        cf.contentInsets = .zero

        let b = UIButton(configuration: cf)
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()
    
    private let filterButtonRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .leading
        row.distribution = .fill
        row.spacing = 8
        return row
    }()
    
    private let periodButton: FilteringButton = {
        let b = FilteringButton()
        b.set(title: "조회 기간", showsChevron: true)
        b.setSelectable(false)
        b.applyFilter(false)
        return b
    }()

    private let stateInfoButton: FilteringButton = {
        let b = FilteringButton()
        b.set(title: "주문 상태 · 정보", showsChevron: true)
        b.setSelectable(false)
        b.applyFilter(false)
        return b
    }()

    private let resetButton: FilteringButton = {
        let b = FilteringButton()
        let icon = UIImage.appImage(asset: .refresh)
        b.set(title: "초기화", iconRight: icon, showsChevron: false)
        b.setSelectable(false)
        b.applyFilter(false)
        b.isHidden = true
        b.alpha = 0
        return b
    }()
    
    // MARK: - Initialization
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        render()
        updateSearchVisibility(animated: false)
        updateEmptyState()
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
        
        searchBar.textField.delegate = self
        
        
        searchBar.textField.addTarget(self, action: #selector(searchTapped(_:)), for: .editingDidBegin)

        
        searchCancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        searchBar.textField.delegate = self

        searchBar.onTextChanged = { text in
            print("검색어: \(text)")
        }
        
        orderHistoryCollectionView.delegate = self
        orderPrepareCollectionView.delegate = self
        
        orderHistoryCollectionView.alwaysBounceVertical = true
        orderPrepareCollectionView.alwaysBounceVertical = true

        
        
        updateSearchVisibility(animated: false)
        
        
    }
    
}

extension OrderHistoryViewController {
    
    private func setUpLayOuts() {
        [orderHistorySegment, orderHistorySeperateView, orderHistoryUnderLineView, filterButtonRow, searchBar, searchCancelButton, searchDimView,orderHistoryCollectionView,orderPrepareCollectionView, emptyStateView, topShadowView].forEach {
            view.addSubview($0)
        }
        
        emptyStateView.isHidden = true
        
        [symbolImageView, ZzzImageView, noOrderHistoryLabel, seeOrderHistoryButton].forEach{
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
            $0.top.equalTo(filterButtonRow.snp.bottom).offset(16)
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
        
        ZzzImageView.snp.makeConstraints{
            $0.top.equalTo(symbolImageView.snp.top)
            $0.leading.equalTo(symbolImageView.snp.leading).offset(-3)
            $0.height.width.equalTo(25)
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
    
    private func render() {
        if let period = currentFilter.period {
            switch period {
            case .m3: periodButton.setTitle("최근 3개월")
            case .m6: periodButton.setTitle("최근 6개월")
            case .y1: periodButton.setTitle("최근 1년")
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
            orderHistoryCollectionView.reloadData()
            
        } else {
            orderPrepareCollectionView.reloadData()
        }
        updateEmptyState()
        refreshShadowForCurrentTab()
    }
}



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
    
    @objc private func resetFilterTapped() {
        currentFilter = .empty
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
    
}

extension OrderHistoryViewController: UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == searchBar.textField && searchCancelButton.isHidden {
            print("터치입력됨")
            
        }
        return true
    }
    
    private func updateEmptyState() {
        let isHistoryTab = (orderHistorySegment.selectedSegmentIndex == 0)
        let isEmptyHistory   = orderHistoryCollectionView.totalItemCount == 0
        let isEmptyPreparing = orderPrepareCollectionView.totalItemCount == 0
        let shouldShowEmpty  = isHistoryTab ? isEmptyHistory : isEmptyPreparing

        noOrderHistoryLabel.text = isHistoryTab ? "주문 내역이 없어요" : "준비 중인 음식이 없어요"
        seeOrderHistoryButton.isHidden = isHistoryTab || !shouldShowEmpty

        emptyStateView.isHidden = !shouldShowEmpty
        
        topShadowView.alpha = shouldShowEmpty ? 0 : topShadowView.alpha


        if isHistoryTab {
            searchBar.isHidden = shouldShowEmpty
            filterButtonRow.isHidden = shouldShowEmpty
            orderHistoryCollectionView.isHidden = shouldShowEmpty

            if shouldShowEmpty { cancelButtonTapped() }
        } else {

            orderPrepareCollectionView.isHidden = shouldShowEmpty
        }
    }
    
    
    //MARK: - ScrollSet
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            return CGSize(width: UIScreen.main.bounds.width - 48 , height: 299)
        }
        return CGSize(width: 0, height: 0)
    }

}


// 셀 확인

private extension UICollectionView {
    var totalItemCount: Int {
        (0..<numberOfSections).reduce(0) { $0 + numberOfItems(inSection: $1) }
    }
}




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
    
    // MARK: - UI Components    
    private let orderHistorySegment: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "지난 주문", at: 0, animated: true)
        segment.insertSegment(withTitle: "준비 중", at: 1, animated: true)
        
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
        
        updateSearchVisibility(animated: false)
    }
    
}

extension OrderHistoryViewController {
    
    private func setUpLayOuts() {
        [orderHistorySegment, orderHistorySeperateView, orderHistoryUnderLineView, filterButtonRow, searchBar, searchCancelButton, searchDimView,orderHistoryCollectionView].forEach {
            view.addSubview($0)
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
            $0.top.equalTo(filterButtonRow.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
            
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
            self.view.layoutIfNeeded()
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
        let hide = (orderHistorySegment.selectedSegmentIndex == 1)

        searchBar.isHidden = hide
        searchCancelButton.isHidden = hide

        if hide {
            topToSearch.deactivate()
            topToFilter?.activate()
        } else {
            topToFilter?.deactivate()
            topToSearch.activate()
        }

        guard animated else { return }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
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

extension OrderHistoryViewController {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == searchBar.textField && searchCancelButton.isHidden {
            print("터치입력됨")
            
        }
        return true
    }
}


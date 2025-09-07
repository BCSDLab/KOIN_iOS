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
    
    // MARK: - Bind
    private func bind() {
        
        orderHistorySegment.addTarget(self, action: #selector(changeSegmentLine(_:)), for: .valueChanged)
        
        [periodButton, stateInfoButton].forEach {
            $0.addTarget(self, action: #selector(showFilterSheet), for: .touchUpInside)
        }
        resetButton.addTarget(self, action: #selector(resetFilterTapped), for: .touchUpInside)

    }
}

extension OrderHistoryViewController {
    
    private func setUpLayOuts() {
        [orderHistorySegment, orderHistorySeperateView, orderHistoryUnderLineView, filterButtonRow].forEach {
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
            $0.top.equalTo(orderHistorySeperateView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
            $0.height.equalTo(34)
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
}

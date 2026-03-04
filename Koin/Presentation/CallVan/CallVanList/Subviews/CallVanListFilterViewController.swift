//
//  CallVanListFilterViewController.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit
import Combine
import Then
import SnapKit

final class CallVanListFilterViewController: UIViewController {
    
    // MARK: - Properties
    @Published private var filter: CallVanListRequest
    private let onApplyButtonTapped: (CallVanListRequest)->Void
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let topSeparatorView = UIView()
    
    private let sortLabel = UILabel()
    private let sortButtonsStackView = UIStackView()
    private let sortLatestDescButton = CallVanFilterButton(title: CallVanListSort.latestDesc.description)
    private let sortDepartureDescButton = CallVanFilterButton(title: CallVanListSort.departureDesc.description)
    private let sortSeparatorView = UIView()
    
    private let stateLabel = UILabel()
    private let stateButtonsStackView = UIStackView()
    private let stateAllButton = CallVanFilterButton(title: "전체")
    private let stateRecruitingButton = CallVanFilterButton(title: CallVanStateDto.recruiting.description)
    private let stateClosedButton = CallVanFilterButton(title: CallVanStateDto.closed.description)
    private let stateSeparatorView = UIView()
    
    private let departureLabel = UILabel()
    private let departureDescriptionLabel = UILabel()
    private let departureButtonsStackView1 = UIStackView()
    private let departureAllButton = CallVanFilterButton(title: "전체")
    private let departureButtons1: [CallVanFilterButton] = [
        CallVanFilterButton(title: CallVanPlace.frontGate.description),
        CallVanFilterButton(title: CallVanPlace.backGate.description),
        CallVanFilterButton(title: CallVanPlace.tennisCourt.description),
        CallVanFilterButton(title: CallVanPlace.dormitoryMain.description)
    ]
    private let departureButtonsStackView2 = UIStackView()
    private let departureButtons2: [CallVanFilterButton] = [
        CallVanFilterButton(title: CallVanPlace.dormitorySub.description),
        CallVanFilterButton(title: CallVanPlace.terminal.description),
        CallVanFilterButton(title: CallVanPlace.station.description),
        CallVanFilterButton(title: CallVanPlace.asanStation.description)
    ]
    private let departureSeparatorView = UIView()
    
    private let arrivalLabel = UILabel()
    private let arrivalDescriptionLabel = UILabel()
    private let arrivalButtonsStackView1 = UIStackView()
    private let arrivalAllButton = CallVanFilterButton(title: "전체")
    private let arrivalButtons1: [CallVanFilterButton] = [
        CallVanFilterButton(title: CallVanPlace.frontGate.description),
        CallVanFilterButton(title: CallVanPlace.backGate.description),
        CallVanFilterButton(title: CallVanPlace.tennisCourt.description),
        CallVanFilterButton(title: CallVanPlace.dormitoryMain.description)
    ]
    private let arrivalButtonsStackView2 = UIStackView()
    private var arrivalButtons2: [CallVanFilterButton] = [
        CallVanFilterButton(title: CallVanPlace.dormitorySub.description),
        CallVanFilterButton(title: CallVanPlace.terminal.description),
        CallVanFilterButton(title: CallVanPlace.station.description),
        CallVanFilterButton(title: CallVanPlace.asanStation.description)
    ]
    private let arrivalSeparatorView = UIView()
    
    private let resetButton = UIButton()
    private let applyButton = UIButton()
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initializer
    init(filter: CallVanListRequest, onApplyButtonTapped: @escaping (CallVanListRequest)->Void) {
        self.filter = filter
        self.onApplyButtonTapped = onApplyButtonTapped
        super.init(nibName: nil, bundle: nil)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        $filter.sink { [weak self] filter in
            guard let self else { return }
            
            // MARK: - Sort
            sortLatestDescButton.isSelected = !(filter.sort == .departureDesc)
            sortDepartureDescButton.isSelected = (filter.sort == .departureDesc)
            
            // MARK: - State
            stateAllButton.isSelected = (filter.state == nil)
            stateRecruitingButton.isSelected = (filter.state == .recruiting)
            stateClosedButton.isSelected = (filter.state == .closed)
            
            // MARK: - Departure
            departureAllButton.isSelected = (filter.departure == nil)
            (departureButtons1 + departureButtons2).forEach { button in
                if let departures = filter.departure {
                    if let departure = CallVanPlace(description: button.title) {
                        button.isSelected = departures.contains(departure)
                    }
                } else {
                    button.isSelected = false
                }
            }
            
            // MARK: - Arrival
            arrivalAllButton.isSelected = (filter.arrival == nil)
            (arrivalButtons1 + arrivalButtons2).forEach { button in
                if let arrivals = filter.arrival {
                    if let arrival = CallVanPlace(description: button.title) {
                        button.isSelected = arrivals.contains(arrival)
                    }
                } else {
                    button.isSelected = false
                }
            }
        }.store(in: &subscriptions)
    }
}

extension CallVanListFilterViewController {
    
    private func configureView() {
        view.backgroundColor = .white
        setUpLayouts()
        setUpStyles()
        setUpConstraints()
        setAddTargets()
    }
    
    private func setUpStyles() {
        // MARK: - Labels
        titleLabel.do {
            $0.text = "필터"
            $0.font = UIFont.appFont(.pretendardBold, size: 18)
            $0.textColor = UIColor.appColor(.new500)
        }
        
        [sortLabel, stateLabel, departureLabel, arrivalLabel].forEach {
            $0.font = UIFont.appFont(.pretendardBold, size: 16)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        sortLabel.text = "정렬"
        stateLabel.text = "모집 상태"
        departureLabel.text = "출발지"
        arrivalLabel.text = "도착지"
        
        [departureDescriptionLabel, arrivalDescriptionLabel].forEach {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.text = "기타 장소는 검색창을 이용해주세요."
        }
        
        // MARK: - StackView
        [sortButtonsStackView, stateButtonsStackView, departureButtonsStackView1, departureButtonsStackView2, arrivalButtonsStackView1, arrivalButtonsStackView2].forEach {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.spacing = 12
        }
        
        // MARK: - Separator View
        [topSeparatorView, sortSeparatorView, stateSeparatorView, departureSeparatorView, arrivalSeparatorView, bottomSeparatorView].forEach {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
        
        // MARK: - Buttons
        closeButton.do {
            $0.setImage(.appImage(asset: .newCancel), for: .normal)
            $0.tintColor = UIColor.appColor(.neutral800)
        }
        resetButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("초기화", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardBold, size: 16),
                .foregroundColor : UIColor.appColor(.neutral600)
            ]))
            configuration.image = UIImage.appImage(asset: .refresh)
            configuration.imagePadding = 8
            configuration.imagePlacement = .trailing
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            $0.configuration = configuration
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        applyButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "적용하기",
                attributes: [
                    .font : UIFont.appFont(.pretendardBold, size: 16),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.cornerRadius = 12
        }
    }
    
    private func setUpLayouts() {
        sortButtonsStackView.addArrangedSubview(sortLatestDescButton)
        sortButtonsStackView.addArrangedSubview(sortDepartureDescButton)
        
        stateButtonsStackView.addArrangedSubview(stateAllButton)
        stateButtonsStackView.addArrangedSubview(stateRecruitingButton)
        stateButtonsStackView.addArrangedSubview(stateClosedButton)
        
        departureButtonsStackView1.addArrangedSubview(departureAllButton)
        departureButtons1.forEach {
            departureButtonsStackView1.addArrangedSubview($0)
        }
        departureButtons2.forEach {
            departureButtonsStackView2.addArrangedSubview($0)
        }
        
        arrivalButtonsStackView1.addArrangedSubview(arrivalAllButton)
        arrivalButtons1.forEach {
            arrivalButtonsStackView1.addArrangedSubview($0)
        }
        arrivalButtons2.forEach {
            arrivalButtonsStackView2.addArrangedSubview($0)
        }
        
        [titleLabel, closeButton, topSeparatorView,
         sortLabel, sortButtonsStackView, sortSeparatorView,
         stateLabel, stateButtonsStackView, stateSeparatorView,
         departureLabel, departureDescriptionLabel, departureButtonsStackView1, departureButtonsStackView2, departureSeparatorView,
         arrivalLabel, arrivalDescriptionLabel, arrivalButtonsStackView1, arrivalButtonsStackView2, arrivalSeparatorView,
         resetButton, applyButton, bottomSeparatorView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        topSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        // MARK: - Sort
        sortLabel.snp.makeConstraints {
            $0.top.equalTo(topSeparatorView).offset(12)
        }
        sortButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(sortLabel.snp.bottom).offset(12)
        }
        sortSeparatorView.snp.makeConstraints {
            $0.top.equalTo(sortButtonsStackView.snp.bottom).offset(12)
        }
        
        // MARK: - State
        stateLabel.snp.makeConstraints {
            $0.top.equalTo(sortSeparatorView.snp.bottom).offset(12)
        }
        stateButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(12)
        }
        stateSeparatorView.snp.makeConstraints {
            $0.top.equalTo(stateButtonsStackView.snp.bottom).offset(12)
        }
        
        // MARK: - Departure
        departureLabel.snp.makeConstraints {
            $0.top.equalTo(stateSeparatorView.snp.bottom).offset(12)
        }
        departureDescriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(departureLabel)
            $0.leading.equalTo(departureLabel.snp.trailing).offset(8)
        }
        departureButtonsStackView1.snp.makeConstraints {
            $0.top.equalTo(departureLabel.snp.bottom).offset(12)
        }
        departureButtonsStackView2.snp.makeConstraints {
            $0.top.equalTo(departureButtonsStackView1.snp.bottom).offset(8)
        }
        departureSeparatorView.snp.makeConstraints {
            $0.top.equalTo(departureButtonsStackView2.snp.bottom).offset(12)
        }
        
        // MARK: - Arrival
        arrivalLabel.snp.makeConstraints {
            $0.top.equalTo(departureSeparatorView.snp.bottom).offset(12)
        }
        arrivalDescriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(arrivalLabel)
            $0.leading.equalTo(arrivalLabel.snp.trailing).offset(8)
        }
        arrivalButtonsStackView1.snp.makeConstraints {
            $0.top.equalTo(arrivalLabel.snp.bottom).offset(12)
        }
        arrivalButtonsStackView2.snp.makeConstraints {
            $0.top.equalTo(arrivalButtonsStackView1.snp.bottom).offset(8)
        }
        arrivalSeparatorView.snp.makeConstraints {
            $0.top.equalTo(arrivalButtonsStackView2.snp.bottom).offset(12)
        }
        
        // MARK: - Buttons
        resetButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(resetButton.intrinsicContentSize.width)
            $0.top.equalTo(arrivalSeparatorView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(32)
        }
        applyButton.snp.makeConstraints {
            $0.top.bottom.equalTo(resetButton)
            $0.leading.equalTo(resetButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-32)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(resetButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        // MARK: - Common
        [sortLabel, stateLabel, departureLabel, arrivalLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(26)
                $0.leading.equalTo(titleLabel)
            }
        }
        [departureDescriptionLabel, arrivalDescriptionLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(19)
            }
        }
        [sortButtonsStackView, stateButtonsStackView, departureButtonsStackView1, departureButtonsStackView2, arrivalButtonsStackView1, arrivalButtonsStackView2].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(34)
                $0.leading.equalTo(titleLabel)
            }
        }
        [sortSeparatorView, stateSeparatorView, departureSeparatorView, arrivalSeparatorView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(1)
                $0.leading.trailing.equalToSuperview().inset(32)
            }
        }
    }
}

extension CallVanListFilterViewController {
    
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        sortLatestDescButton.addTarget(self, action: #selector(sortLatestDescButtonTapped), for: .touchUpInside) // 최신순
        sortDepartureDescButton.addTarget(self, action: #selector(sortDepartureDescButtonTapped), for: .touchUpInside) // 출발시각순
        
        stateAllButton.addTarget(self, action: #selector(stateAllButtonTapped), for: .touchUpInside) // 모집상태 전체
        stateRecruitingButton.addTarget(self, action: #selector(stateButtonTapped), for: .touchUpInside)
        stateClosedButton.addTarget(self, action: #selector(stateButtonTapped), for: .touchUpInside)
        
        departureAllButton.addTarget(self, action: #selector(departureAllButtonTapped), for: .touchUpInside)
        departureButtons1.forEach {
            $0.addTarget(self, action: #selector(departureButtonTapped), for: .touchUpInside)
        }
        departureButtons2.forEach {
            $0.addTarget(self, action: #selector(departureButtonTapped), for: .touchUpInside)
        }
        
        arrivalAllButton.addTarget(self, action: #selector(arrivalAllButtonTapped), for: .touchUpInside)
        arrivalButtons1.forEach {
            $0.addTarget(self, action: #selector(arrivalButtonTapped), for: .touchUpInside)
        }
        arrivalButtons2.forEach {
            $0.addTarget(self, action: #selector(arrivalButtonTapped), for: .touchUpInside)
        }
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismissView()
    }
    
    // MARK: SORT
    @objc private func sortLatestDescButtonTapped() {
        filter.sort = .latestDesc
        sortLatestDescButton.isSelected = true
        sortDepartureDescButton.isSelected = false
    }
    @objc private func sortDepartureDescButtonTapped() {
        filter.sort = .departureDesc
        sortLatestDescButton.isSelected = false
        sortDepartureDescButton.isSelected = true
    }
    
    // MARK: - State
    @objc private func stateAllButtonTapped() {
        filter.state = nil
    }
    @objc private func stateButtonTapped(_ sender: UIButton) {
        if let filterButton = sender as? CallVanFilterButton,
           let state = CallVanStateDto(description: filterButton.title) {
            filter.state = state
        }
    }
    
    // MARK: - Departure
    @objc private func departureAllButtonTapped() {
        filter.departure = nil
    }
    @objc private func departureButtonTapped(_ sender: UIButton) {
        if let filterButton = sender as? CallVanFilterButton,
           let departure = CallVanPlace(description: filterButton.title) {
            if var departures = filter.departure {
                if departures.contains(departure) {
                    departures = departures.filter { $0 != departure }
                } else {
                    departures.append(departure)
                }
                filter.departure = departures
            } else {
                filter.departure = [departure]
            }
        }
    }
    
    // MARK: - Arrival
    @objc private func arrivalAllButtonTapped() {
        filter.arrival = nil
    }
    @objc private func arrivalButtonTapped(_ sender: UIButton) {
        if let filterButton = sender as? CallVanFilterButton,
           let arrival = CallVanPlace(description: filterButton.title) {
            if var arrivals = filter.arrival {
                if arrivals.contains(arrival) {
                    arrivals = arrivals.filter { $0 != arrival }
                } else {
                    arrivals.append(arrival)
                }
                filter.arrival = arrivals
            } else {
                filter.arrival = [arrival]
            }
        }
    }
    
    // MARK: - 
    @objc private func resetButtonTapped() {
        self.filter = CallVanListRequest()
    }
    @objc private func applyButtonTapped() {
        onApplyButtonTapped(filter)
        dismissView()
    }
}

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
    private let isLoggedIn: Bool
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let topSeparatorView = UIView()
    
    private let listLabel = UILabel()
    private let listButtonsStackView = UIStackView()
    private let listButtons = [
        CallVanFilterButton(filterState: CallVanMineOrJoined.all),
        CallVanFilterButton(filterState: CallVanMineOrJoined.mine),
        CallVanFilterButton(filterState: CallVanMineOrJoined.joined)
    ]
    private let listSeparatorView = UIView()
    private let sortLabel = UILabel()
    private let sortButtonsStackView = UIStackView()
    private let sortButtons = [
        CallVanFilterButton(filterState: CallVanListSort.latestDesc),
        CallVanFilterButton(filterState: CallVanListSort.departureDesc)
    ]
    private let sortSeparatorView = UIView()
    
    private let stateLabel = UILabel()
    private let stateButtonsStackView = UIStackView()
    private let stateButtons = [
        CallVanFilterButton(filterState: CallVanRecruitmentState.all),
        CallVanFilterButton(filterState: CallVanRecruitmentState.recruiting),
        CallVanFilterButton(filterState: CallVanRecruitmentState.closed)
    ]
    private let stateSeparatorView = UIView()
    
    private let departureLabel = UILabel()
    private let departureDescriptionLabel = UILabel()
    private let departureButtonsStackView1 = UIStackView()
    private let departureButtons1 = [
        CallVanFilterButton(filterState: CallVanPlace.all),
        CallVanFilterButton(filterState: CallVanPlace.frontGate),
        CallVanFilterButton(filterState: CallVanPlace.backGate),
        CallVanFilterButton(filterState: CallVanPlace.terminal)
    ]
    private let departureButtonsStackView2 = UIStackView()
    private let departureButtons2: [CallVanFilterButton] = [
        CallVanFilterButton(filterState: CallVanPlace.dormitoryMain),
        CallVanFilterButton(filterState: CallVanPlace.dormitorySub),
        CallVanFilterButton(filterState: CallVanPlace.station),
        CallVanFilterButton(filterState: CallVanPlace.asanStation)
    ]
    private let departureSeparatorView = UIView()
    
    private let arrivalLabel = UILabel()
    private let arrivalDescriptionLabel = UILabel()
    private let arrivalButtonsStackView1 = UIStackView()
    private let arrivalButtons1: [CallVanFilterButton] = [
        CallVanFilterButton(filterState: CallVanPlace.all),
        CallVanFilterButton(filterState: CallVanPlace.frontGate),
        CallVanFilterButton(filterState: CallVanPlace.backGate),
        CallVanFilterButton(filterState: CallVanPlace.terminal)
    ]
    private let arrivalButtonsStackView2 = UIStackView()
    private var arrivalButtons2: [CallVanFilterButton] = [
        CallVanFilterButton(filterState: CallVanPlace.dormitoryMain),
        CallVanFilterButton(filterState: CallVanPlace.dormitorySub),
        CallVanFilterButton(filterState: CallVanPlace.station),
        CallVanFilterButton(filterState: CallVanPlace.asanStation)
    ]
    private let arrivalSeparatorView = UIView()
    
    private let resetButton = UIButton()
    private let applyButton = UIButton()
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initializer
    init(
        filter: CallVanListRequest,
        onApplyButtonTapped: @escaping (CallVanListRequest)->Void,
        isLoggedIn: Bool
    ) {
        self.filter = filter
        self.onApplyButtonTapped = onApplyButtonTapped
        self.isLoggedIn = isLoggedIn
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
            
            // MARK: - List
            listButtons.forEach { button in
                button.isSelected = button.filterState as! CallVanMineOrJoined == filter.mineOrJoined
            }
            
            // MARK: - Sort
            sortButtons.forEach { button in
                button.isSelected = button.filterState as! CallVanListSort == filter.sort
            }
            
            // MARK: - State
            stateButtons.forEach { button in
                button.isSelected = button.filterState as! CallVanRecruitmentState == filter.state
            }
            
            // MARK: - Departure
            if filter.departure == [.all] {
                (departureButtons1 + departureButtons2).forEach { button in
                    button.isSelected = false
                }
                departureButtons1.first?.isSelected = true
            } else {
                (departureButtons1 + departureButtons2).forEach { button in
                    button.isSelected = filter.departure.contains(button.filterState as! CallVanPlace)
                }
            }
            
            // MARK: - Arrival
            if filter.arrival == [.all] {
                (arrivalButtons1 + arrivalButtons2).forEach { button in
                    button.isSelected = false
                }
                arrivalButtons1.first?.isSelected = true
            } else {
                (arrivalButtons1 + arrivalButtons2).forEach { button in
                    button.isSelected = filter.arrival.contains(button.filterState as! CallVanPlace)
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
        
        [listLabel, sortLabel, stateLabel, departureLabel, arrivalLabel].forEach {
            $0.font = UIFont.appFont(.pretendardBold, size: 16)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        listLabel.text = "목록"
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
        [listButtonsStackView, sortButtonsStackView, stateButtonsStackView, departureButtonsStackView1, departureButtonsStackView2, arrivalButtonsStackView1, arrivalButtonsStackView2].forEach {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.spacing = 12
        }
        
        // MARK: - Separator View
        [topSeparatorView, listSeparatorView, sortSeparatorView, stateSeparatorView, departureSeparatorView, arrivalSeparatorView, bottomSeparatorView].forEach {
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
        listButtons.forEach {
            listButtonsStackView.addArrangedSubview($0)
        }
        sortButtons.forEach {
            sortButtonsStackView.addArrangedSubview($0)
        }
        stateButtons.forEach {
            stateButtonsStackView.addArrangedSubview($0)
        }
        departureButtons1.forEach {
            departureButtonsStackView1.addArrangedSubview($0)
        }
        departureButtons2.forEach {
            departureButtonsStackView2.addArrangedSubview($0)
        }
        arrivalButtons1.forEach {
            arrivalButtonsStackView1.addArrangedSubview($0)
        }
        arrivalButtons2.forEach {
            arrivalButtonsStackView2.addArrangedSubview($0)
        }
        
        [titleLabel, closeButton, topSeparatorView,
         listLabel, listButtonsStackView, listSeparatorView,
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
        
        // MARK: - List
        listLabel.snp.makeConstraints {
            $0.top.equalTo(topSeparatorView).offset(12)
        }
        listButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(listLabel.snp.bottom).offset(12)
        }
        listSeparatorView.snp.makeConstraints {
            $0.top.equalTo(listButtonsStackView.snp.bottom).offset(12)
        }
        
        // MARK: - Sort
        sortLabel.snp.makeConstraints {
            $0.top.equalTo(listSeparatorView.snp.bottom).offset(12)
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
        [listLabel, sortLabel, stateLabel, departureLabel, arrivalLabel].forEach {
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
        [listButtonsStackView, sortButtonsStackView, stateButtonsStackView, departureButtonsStackView1, departureButtonsStackView2, arrivalButtonsStackView1, arrivalButtonsStackView2].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(34)
                $0.leading.equalTo(titleLabel)
            }
        }
        [listSeparatorView, sortSeparatorView, stateSeparatorView, departureSeparatorView, arrivalSeparatorView].forEach {
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
        
        listButtons.forEach {
            $0.addTarget(self, action: #selector(listButtonTapped(_:)), for: .touchUpInside)
        }
        sortButtons.forEach {
            $0.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
        }
        stateButtons.forEach {
            $0.addTarget(self, action: #selector(stateButtonTapped(_:)), for: .touchUpInside)
        }
        (departureButtons1 + departureButtons2).forEach {
            $0.addTarget(self, action: #selector(departureButtonTapped(_:)), for: .touchUpInside)
        }
        (arrivalButtons1 + arrivalButtons2).forEach {
            $0.addTarget(self, action: #selector(arrivalButtonTapped(_:)), for: .touchUpInside)
        }
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismissView()
    }
    
    @objc private func listButtonTapped(_ sender: UIButton) {
        guard let listButton = sender as? CallVanFilterButton,
              let state = listButton.filterState as? CallVanMineOrJoined else {
            return
        }
        if state != .all && isLoggedIn != true {
            showToastMessage(message: "로그인이 필요한 기능입니다.")
        } else {
            filter.mineOrJoined = state
        }
    }
    
    @objc private func sortButtonTapped(_ sender: UIButton) {
        if let sortButton = sender as? CallVanFilterButton,
           let sort = sortButton.filterState as? CallVanListSort {
            filter.sort = sort
        }
    }

    @objc private func stateButtonTapped(_ sender: UIButton) {
        if let stateButton = sender as? CallVanFilterButton,
           let state = stateButton.filterState as? CallVanRecruitmentState {
            filter.state = state
        }
    }
    
    // MARK: - Departure
    @objc private func departureButtonTapped(_ sender: UIButton) {
        guard let departureButton = sender as? CallVanFilterButton,
              let departure = departureButton.filterState as? CallVanPlace else {
            return
        }
        if departure == .all {
            filter.departure = [.all]
        } else {
            filter.departure.remove(.all)
            if filter.departure == [departure] {
                return
            } else {
                filter.departure.formSymmetricDifference([departure])
            }
        }
    }
    
    // MARK: - Arrival
    @objc private func arrivalButtonTapped(_ sender: UIButton) {
        guard let arrivalButton = sender as? CallVanFilterButton,
              let arrival = arrivalButton.filterState as? CallVanPlace else {
            return
        }
        if arrival == .all {
            filter.arrival = [.all]
        } else {
            filter.arrival.remove(.all)
            if filter.arrival == [arrival] {
                return
            } else {
                filter.arrival.formSymmetricDifference([arrival])
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

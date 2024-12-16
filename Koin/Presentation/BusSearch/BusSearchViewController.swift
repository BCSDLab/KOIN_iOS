//
//  BusSearchViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import DropDown
import SnapKit
import UIKit

final class BusSearchViewController: CustomViewController {
    
    private let viewModel: BusSearchViewModel
    private let inputSubject: PassthroughSubject<BusSearchViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let searchMainDescriptionLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "목적지까지 가장 빠른 교통편을 알려드릴게요."
    }
    
    private let searchSubDescriptionLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral600)
        $0.text = "학기 중 시간표와 다를 수 있습니다."
    }
    
    private let departGuideLabel = UILabel().then {
        $0.text = "출발"
    }
    
    private let arriveGuideLabel = UILabel().then {
        $0.text = "도착"
    }
    
    private let departAreaSelectedButton = UIButton()
    
    private let arrivedAreaSelectedButton = UIButton()
    
    private let swapAreaButton = UIButton().then {
        $0.setImage(.appImage(asset: .swap), for: .normal)
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
    }
    
    private let busInfoSearchButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(string: "조회하기", attributes: [.font: UIFont.appFont(.pretendardMedium, size: 15)]), for: .normal)
        $0.backgroundColor = .appColor(.neutral300)
        $0.tintColor = .appColor(.neutral600)
        $0.layer.cornerRadius = 4
    }
    
    private let busAreaViewController = BusAreaSelectedViewController()
    
    // MARK: - Initialization
    
    init(viewModel: BusSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setUpNavigationBar()
        setNavigationTitle(title: "교통편 조회하기")
        bind()
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        busAreaViewController.busAreaPublisher.sink { [weak self] busArea, btnType in
            let sender: UIButton
            guard let self = self else { return }
            if btnType == 0 { //출발
                sender = departAreaSelectedButton
            }
            else { //도착
                sender = arrivedAreaSelectedButton
            }
            self.changeBusAreaButton(sender: sender, title: busArea.koreanDescription)
        }.store(in: &subscriptions)
    }
}

extension BusSearchViewController {
    @objc private func tapBusAreaSelectedButtons(sender: UIButton) {
        let busRouteType: Int
        if sender == departAreaSelectedButton {
            busRouteType = 0
        }
        else {
           busRouteType = 1
        }
        busAreaViewController.configure(busRouteType: busRouteType, busAreaLists: [(.koreatech, true), (.station, false), (.terminal, false)])
        let bottomSheet = BottomSheetViewController(contentViewController: busAreaViewController, defaultHeight: 361, cornerRadius: 32, isPannedable: false)
        self.present(bottomSheet, animated: true)
    }
    
    private func changeBusAreaButton(sender: UIButton, title: String) {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.appFont(.pretendardBold, size: 18), .foregroundColor: UIColor.appColor(.neutral800)]))
        configuration.contentInsets = .init(top: 12, leading: 30, bottom: 12, trailing: 30)
        sender.configuration = configuration
        sender.backgroundColor = .clear
    }
}


extension BusSearchViewController {
    
    private func setUpLabels() {
        [departGuideLabel, arriveGuideLabel].forEach {
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textColor = .appColor(.primary500)
            $0.textAlignment = .center
        }
    }

    private func setUpButtons() {
        let buttonNames = ["출발지 선택", "도착지 선택"]
        let buttons = [departAreaSelectedButton, arrivedAreaSelectedButton]
        for (index, value) in buttons.enumerated() {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(buttonNames[index], attributes: AttributeContainer([.font: UIFont.appFont(.pretendardRegular, size: 14), .foregroundColor: UIColor.appColor(.gray)]))
            configuration.contentInsets = .init(top: 12, leading: 30, bottom: 12, trailing: 30)
            value.configuration = configuration
            value.backgroundColor = .appColor(.neutral100)
            value.addTarget(self, action: #selector(tapBusAreaSelectedButtons), for: .touchUpInside)
        }
    }
    
    private func setUpLayOuts() {
        [navigationBarWrappedView, searchMainDescriptionLabel, searchSubDescriptionLabel, departGuideLabel, arriveGuideLabel, departAreaSelectedButton, swapAreaButton, arrivedAreaSelectedButton, busInfoSearchButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(45)
        }
        searchMainDescriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(navigationBarWrappedView.snp.bottom).offset(16)
        }
        searchSubDescriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(searchMainDescriptionLabel)
            $0.top.equalTo(searchMainDescriptionLabel.snp.bottom).offset(4)
        }
        departGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(127)
            $0.top.equalTo(searchSubDescriptionLabel.snp.bottom).offset(46)
        }
        arriveGuideLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(127)
            $0.top.equalTo(departGuideLabel)
        }
        departAreaSelectedButton.snp.makeConstraints {
            $0.centerX.equalTo(departGuideLabel)
            $0.top.equalTo(departGuideLabel.snp.bottom).offset(8)
            $0.width.equalTo(143)
            $0.height.equalTo(46)
        }
        arrivedAreaSelectedButton.snp.makeConstraints {
            $0.centerX.equalTo(arriveGuideLabel)
            $0.top.equalTo(departAreaSelectedButton)
            $0.width.equalTo(143)
            $0.height.equalTo(46)
        }
        swapAreaButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(arrivedAreaSelectedButton)
        }
        busInfoSearchButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(59)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLabels()
        setUpButtons()
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

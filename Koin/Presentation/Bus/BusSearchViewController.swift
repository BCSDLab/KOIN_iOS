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
    
    private let busInfoSearchButton = UIView().then {
        let label = UILabel()
        label.text = "조회하기"
        label.font = UIFont.appFont(.pretendardMedium, size: 15)
        label.textColor = .appColor(.neutral600)
        $0.addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        $0.backgroundColor = .appColor(.neutral300)
        $0.layer.cornerRadius = 4
    }
   
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
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
    }
}

extension BusSearchViewController {
    
   
    
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
        let buttonNames = ["출발지 선택", "목적지 선택"]
        let buttons = [departAreaSelectedButton, arrivedAreaSelectedButton]
        for (index, value) in buttons.enumerated() {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(buttonNames[index], attributes: AttributeContainer([.font: UIFont.appFont(.pretendardRegular, size: 14), .foregroundColor: UIColor.appColor(.gray)]))
            configuration.contentInsets = .init(top: 12, leading: 30, bottom: 12, trailing: 30)
            value.configuration = configuration
            value.backgroundColor = .appColor(.neutral100)
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

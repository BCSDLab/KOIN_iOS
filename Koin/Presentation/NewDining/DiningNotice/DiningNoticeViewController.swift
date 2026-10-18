//
//  DiningNoticeViewController.swift
//  koin
//
//  Created by 김나훈 on 6/8/24.
//

import Combine
import UIKit

final class DiningNoticeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: DiningNoticeViewModel
    private let inputSubject: PassthroughSubject<DiningNoticeViewModel.Input, Never> = .init()
    
    // MARK: - UI Components
    private let diningGuideLabel = UILabel().then { _ in
    }
    
    private let placeGuideLabel = UILabel().then {
        $0.text = "위치"
    }
    
    private let placeTextLabel = UILabel().then { _ in
    }
    
    private let phoneGuideLabel = UILabel().then {
        $0.text = "전화번호"
    }
    
    private let phoneTextLabel = UILabel().then { _ in
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let weekdayTimeLabel = UILabel().then {
        $0.text = "평일 운영시간"
    }
    
    private let weekdayTimeCollectionView = DiningOperatingTimeCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 0
        }
    )
    
    private let weekendTimeLabel = UILabel().then {
        $0.text = "주말 운영시간"
    }
    
    private let weekendTimeCollectionView = DiningOperatingTimeCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 0
        }
    )
    
    private let updateDateLabel = UILabel().then { _ in
    }
    
    // MARK: - Initialization
    init(viewModel: DiningNoticeViewModel) {
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
        bind()
        inputSubject.send(.fetchCoopShopList)
        navigationItem.title = "학생식당 정보"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .empty)
    }

    // MARK: - Bind
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case .showCoopShopData(let response):
                self?.showCoopShopData(response)
            }
        }.store(in: &subscriptions)
    }
    
}

extension DiningNoticeViewController {

    private func showCoopShopData(_ response: CoopShopData) {
        diningGuideLabel.text = "\(response.name) \(response.semester)중 운영시간"
        placeTextLabel.text = response.location
        phoneTextLabel.text = response.phone
        updateDateLabel.text = response.updatedAt
        if response.opens.count >= 3 {
            weekdayTimeCollectionView.setUpTimeText([response.opens[0], response.opens[1], response.opens[2]])
        }
        else { 
            weekdayTimeCollectionView.isHidden = true
        }
        if response.opens.count >= 6 {
                weekendTimeCollectionView.setUpTimeText([response.opens[3], response.opens[4], response.opens[5]])
        }
        else {
            weekendTimeCollectionView.isHidden = true
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension DiningNoticeViewController {
    private func setUpLayOuts() {
        [updateDateLabel, diningGuideLabel, placeGuideLabel, placeTextLabel, phoneGuideLabel, phoneTextLabel, separateView, weekdayTimeLabel, weekdayTimeCollectionView, weekendTimeLabel, weekendTimeCollectionView].forEach {
            self.view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        diningGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            make.leading.equalTo(updateDateLabel.snp.leading)
            make.height.equalTo(32)
        }
        placeGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(diningGuideLabel.snp.bottom)
            make.leading.equalTo(updateDateLabel.snp.leading)
            make.height.equalTo(22)
        }
        placeTextLabel.snp.makeConstraints { make in
            make.top.equalTo(diningGuideLabel.snp.bottom)
            make.leading.equalTo(placeGuideLabel.snp.trailing).offset(8)
            make.height.equalTo(placeGuideLabel.snp.height)
        }
        phoneGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(placeGuideLabel.snp.bottom)
            make.leading.equalTo(updateDateLabel.snp.leading)
            make.height.equalTo(placeGuideLabel.snp.height)
        }
        phoneTextLabel.snp.makeConstraints { make in
            make.top.equalTo(placeGuideLabel.snp.bottom)
            make.leading.equalTo(phoneGuideLabel.snp.trailing).offset(8)
            make.height.equalTo(placeGuideLabel.snp.height)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(phoneGuideLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }
        weekdayTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(16)
            make.leading.equalTo(updateDateLabel.snp.leading)
        }
        weekdayTimeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(weekdayTimeLabel.snp.bottom).offset(12)
            make.leading.equalTo(updateDateLabel.snp.leading)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(132)
        }
        weekendTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(weekdayTimeCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(updateDateLabel.snp.leading)
        }
        weekendTimeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(weekendTimeLabel.snp.bottom).offset(12)
            make.leading.equalTo(updateDateLabel.snp.leading)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(132)
        }
        updateDateLabel.snp.makeConstraints { make in
            make.top.equalTo(weekendTimeCollectionView.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.height.equalTo(19)
        }
    }
    
    private func setUpLabels() {
        [phoneTextLabel, placeTextLabel, updateDateLabel, phoneGuideLabel, placeGuideLabel, diningGuideLabel, weekdayTimeLabel, weekendTimeLabel].forEach { label in
            label.contentMode = .center
        }
        updateDateLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        updateDateLabel.textColor = UIColor.appColor(.neutral500)
        
        diningGuideLabel.font = UIFont.appFont(.pretendardBold, size: 20)
        diningGuideLabel.textColor = UIColor.appColor(.neutral800)
        
        [placeGuideLabel, phoneGuideLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardMedium, size: 14)
            label.textColor = UIColor.appColor(.neutral600)
        }
        [placeTextLabel, phoneTextLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardRegular, size: 14)
            label.textColor = UIColor.appColor(.neutral600)
        }
        [weekdayTimeLabel, weekendTimeLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardBold, size: 18)
            label.textColor = UIColor.appColor(.primary500)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpLabels()
        self.view.backgroundColor = .systemBackground
    }
}


//
//  NotiViewController.swift
//  koin
//
//  Created by 김나훈 on 4/18/24.
//

import Combine
import SnapKit
import UIKit

final class NotiViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: NotiViewModel
    private let inputSubject: PassthroughSubject<NotiViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    var mealViews: [UIView] = []
    var mealSwitches: [UISwitch] = []
    var mealLabels: [UILabel] = []
    
    // MARK: - UI Components
    
    private let stackView: UIView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
        
    }()
    
    private let soldOutWrapView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let diningImageUploadWrapView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let eventWrapView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let diningGuideLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 24.0
        let attributedString = NSAttributedString(string: "식단", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.attributedText = attributedString
        return label
    }()
    
    private let soldOutNotiLabel: UILabel = {
        let label = UILabel()
        label.text = "품절 알림"
        return label
    }()
    
    private let soldOutSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.onTintColor = UIColor.appColor(.primary500)
        return uiSwitch
    }()
    
    private let diningImageUploadNotiLabel: UILabel = {
        let label = UILabel()
        label.text = "식단 사진 업로드 알림"
        return label
    }()
    
    private let diningImageUploadSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.onTintColor = UIColor.appColor(.primary500)
        return uiSwitch
    }()
    
    private let shopGuideLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 24.0
        let attributedString = NSAttributedString(string: "주변상점", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.attributedText = attributedString
        return label
    }()
    
    private let eventNotiLabel: UILabel = {
        let label = UILabel()
        label.text = "이벤트 알림"
        return label
    }()
    
    private let eventSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.onTintColor = UIColor.appColor(.primary500)
        return uiSwitch
    }()
    
    private let soldOutDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "식단이 품절될 경우 알림을 받습니다."
        return label
    }()
    
    private let diningImageUploadDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "식단사진이 업로드 될 경우 알림을 받습니다."
        return label
    }()
    
    private let eventDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 주변상점의 이벤트 알림을 받습니다."
        return label
    }()
    
    private func setupTimeWrapView() {
        let meals = ["아침 식단", "점심 식단", "저녁 식단"]
        
        for meal in meals {
            let wrapView = UIView()
            // 라벨 생성
            let label = UILabel()
            label.text = meal
            label.textColor = UIColor.appColor(.neutral600)
            wrapView.addSubview(label)
            label.snp.makeConstraints { label in
                label.height.equalTo(26)
                label.top.equalToSuperview().inset(16)
                label.leading.equalToSuperview().inset(32)
            }
            self.mealLabels.append(label)
            // 스위치 생성
            let switchControl = UISwitch()
            switchControl.onTintColor = UIColor.appColor(.primary500)
            wrapView.addSubview(switchControl)
            switchControl.transform = CGAffineTransformMakeScale(0.9, 0.75)
            switchControl.snp.makeConstraints { switchControl in
                switchControl.trailing.equalToSuperview().inset(21)
                switchControl.top.equalToSuperview().inset(15)
            }
            mealSwitches.append(switchControl)
            self.mealViews.append(wrapView)
        }
    }
    
    // MARK: - Initialization
    
    init(viewModel: NotiViewModel) {
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
        bind()
        setupTimeWrapView()
        configureView()
        inputSubject.send(.getNotiAgreementList)
        soldOutSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        eventSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        diningImageUploadSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        mealSwitches.forEach { switchControl in
            switchControl.addTarget(self, action: #selector(switchDetailValueChanged), for: .valueChanged)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setNavigationBar()
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateSwitch(notiList):
                self?.changeSwitch(notiList)
            case .requestLogInAgain:
                self?.requestLogInAgain()
            case let .changeButtonEnableStatus(isEnable):
                self?.changeMealSwitchEnableStatus(isEnable)
            }
        }.store(in: &subscriptions)
    }
    
}

extension NotiViewController {
    
    private func changeMealSwitchEnableStatus(_ isEnable: Bool) {
        mealSwitches.forEach { uiSwitch in
            uiSwitch.isEnabled = isEnable
        }
    }
    func requestLogInAgain() {
        let alertController = UIAlertController(title: "세션 만료", message: "세션이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    @objc private func switchValueChanged(_ sender: UISwitch) {
        
        switch sender {
        case soldOutSwitch: inputSubject.send(.switchChanged(.diningSoldOut, sender.isOn))
        case diningImageUploadSwitch: inputSubject.send(.switchChanged(.diningImageUpload, sender.isOn))
        default: inputSubject.send(.switchChanged(.shopEvent, sender.isOn))
        }
    }
    
    
    @objc private func switchDetailValueChanged(_ sender: UISwitch) {
        
        var senderType: DetailSubscribeType = .breakfast
        
        switch sender {
        case mealSwitches[0]:
            senderType = .breakfast
        case mealSwitches[1]:
            senderType = .lunch
        case mealSwitches[2]:
            senderType = .dinner
        default:
            print("none")
        }
        
        
        inputSubject.send(.switchDetailChanged(senderType, sender.isOn))
    }
    
    private func changeSwitch(_ dto: NotiAgreementDTO) {
        
        dto.subscribes?.forEach { subscribe in
            switch subscribe.type {
            case .diningSoldOut:
                let isPermitSoldOut = subscribe.isPermit ?? false
                soldOutSwitch.isOn = isPermitSoldOut
                mealSwitches.forEach { uiSwitch in
                    uiSwitch.isEnabled = isPermitSoldOut
                }
            case .shopEvent:
                eventSwitch.isOn = subscribe.isPermit ?? false
            case .diningImageUpload:
                diningImageUploadSwitch.isOn = subscribe.isPermit ?? false
            default:
                print("none")
            }
            
            subscribe.detailSubscribes?.forEach { subscribe in
                switch subscribe.detailType {
                case .breakfast:
                    mealSwitches[0].isOn = subscribe.isPermit ?? false
                case .lunch:
                    mealSwitches[1].isOn = subscribe.isPermit ?? false
                case .dinner:
                    mealSwitches[2].isOn = subscribe.isPermit ?? false
                case .none:
                    print("none")
                }
            }
        }
    }
    
}

extension NotiViewController {
    
    private func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func setUpLayOuts() {
        
        [diningGuideLabel, soldOutWrapView].forEach {
            self.view.addSubview($0)
        }
        
        mealViews.forEach {
            self.view.addSubview($0)
        }
        
        [diningImageUploadWrapView].forEach {
            self.view.addSubview($0)
        }
        
        [shopGuideLabel, eventWrapView].forEach {
            self.view.addSubview($0)
        }
        
        [soldOutNotiLabel, soldOutSwitch, soldOutDescriptionLabel].forEach {
            soldOutWrapView.addSubview($0)
        }
        
        [diningImageUploadNotiLabel, diningImageUploadSwitch, diningImageUploadDescriptionLabel].forEach {
            diningImageUploadWrapView.addSubview($0)
        }
        
        [eventNotiLabel, eventSwitch, eventDescriptionLabel].forEach {
            eventWrapView.addSubview($0)
        }
        
    }
    
    private func setUpConstraints() {
        diningGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(33)
        }
        
        soldOutWrapView.snp.makeConstraints { make in
            make.top.equalTo(diningGuideLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        soldOutNotiLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.height.equalTo(26)
            make.top.equalTo(16)
        }
        
        soldOutSwitch.transform = CGAffineTransformMakeScale(0.9, 0.75)
        soldOutSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(21)
            make.top.equalToSuperview().inset(15)
        }
        soldOutDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(soldOutNotiLabel.snp.bottom).offset(8)
            make.height.equalTo(17)
        }
        
        var previousView: UIView = soldOutWrapView
        
        for mealView in mealViews {
            mealView.snp.makeConstraints { make in
                make.top.equalTo(previousView.snp.bottom) // 간격 조정
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(58)
            }
            previousView = mealView
        }
        
        diningImageUploadWrapView.snp.makeConstraints { make in
            make.top.equalTo(mealViews[2].snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        diningImageUploadNotiLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.height.equalTo(26)
            make.top.equalTo(16)
        }
        
        diningImageUploadSwitch.transform = CGAffineTransformMakeScale(0.9, 0.75)
        diningImageUploadSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(21)
            make.top.equalToSuperview().inset(15)
        }
        diningImageUploadDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(diningImageUploadNotiLabel.snp.bottom).offset(8)
            make.height.equalTo(17)
        }
    
        shopGuideLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(diningImageUploadWrapView.snp.bottom)
            make.height.equalTo(33)
        }
        
        eventWrapView.snp.makeConstraints { make in
            make.top.equalTo(shopGuideLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        eventNotiLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.height.equalTo(26)
            make.top.equalTo(16)
        }
        
        eventSwitch.transform = CGAffineTransformMakeScale(0.9, 0.75)
        eventSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(21)
            make.top.equalToSuperview().inset(15)
        }
        eventDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(eventNotiLabel.snp.bottom).offset(8)
            make.height.equalTo(17)
        }
    }
    
    private func setUpViewDetails() {
        [diningGuideLabel, shopGuideLabel].forEach { label in
            label.backgroundColor = UIColor.appColor(.neutral50)
            label.textColor = UIColor.appColor(.neutral600)
            label.font = UIFont.appFont(.pretendardMedium, size: 14)
            label.contentMode = .center
        }
        
        [soldOutNotiLabel, diningImageUploadNotiLabel, eventNotiLabel].forEach { label in
            label.textColor = UIColor.appColor(.neutral800)
            label.contentMode = .center
            label.font = UIFont.appFont(.pretendardMedium, size: 16)
        }
        
        [soldOutDescriptionLabel, diningImageUploadDescriptionLabel, eventDescriptionLabel].forEach { label in
            label.textColor = UIColor.appColor(.neutral500)
            label.contentMode = .center
            label.font = UIFont.appFont(.pretendardRegular, size: 13)
        }
        
        [soldOutWrapView, diningImageUploadWrapView, eventWrapView].forEach { view in
            view.backgroundColor = .systemBackground
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.appColor(.neutral100).cgColor
        }
        
        mealLabels.forEach { label in
            label.textColor = UIColor.appColor(.neutral600)
            label.contentMode = .center
            label.font = UIFont.appFont(.pretendardRegular, size: 16)
        }
        
        mealViews.forEach { view in
            view.layer.borderColor = UIColor.appColor(.neutral100).cgColor
            view.layer.borderWidth = 0.5
        }
        
        stackView.layer.borderColor = UIColor.appColor(.neutral100).cgColor
        stackView.layer.borderWidth = 0.5
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpViewDetails()
        self.view.backgroundColor = .systemBackground
    }
}

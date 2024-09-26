//
//  ManageNoticeKeyWordViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class ManageNoticeKeywordViewController: CustomViewController {
    // MARK: - Properties
    
    private let viewModel: ManageNoticeKeywordViewModel
    private let inputSubject: PassthroughSubject<ManageNoticeKeywordViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components

    private let myKeywordGuideLabel = UILabel().then {
        $0.text = "내 키워드"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let numberOfKeywordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
    }
    
    private let addKeywordDescriptionLabel = UILabel().then {
        $0.text = "키워드는 최대 10개까지 추가 가능합니다."
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
    }
    
    private let textField = UITextField().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        let leftMarginView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftView = leftMarginView
        $0.leftViewMode = .always
        $0.attributedPlaceholder = NSAttributedString(string: "알림받을 키워드를 추가해주세요.", attributes: [.font: UIFont.appFont(.pretendardRegular, size: 14), .foregroundColor: UIColor.appColor(.gray)])
        $0.layer.cornerRadius = 4
    }
    
    private let addKeywordButton = UIButton().then {
        $0.setTitle("추가", for: .normal)
        $0.titleLabel?.font = .appFont(.pretendardMedium, size: 13)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.backgroundColor = .appColor(.neutral300)
        $0.layer.cornerRadius = 4
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let keywordNotificationGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.text = "키워드 알림"
    }
    
    private let keywordNotificationLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.text = "키워드 알림받기"
    }
    
    private let keywordNotificationDescriptionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.text = "키워드가 포함된 게시물의 알림을 받을 수 있습니다."
    }
    
    private let keywordNotificationSwtich = UISwitch().then {
        $0.preferredStyle = .automatic
    }
    
    private let recommendedKeywordGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "추천 키워드"
    }
    
    private let keywordLoginModalViewController = LoginModalViewController(width: 301, height: 230, paddingBetweenLabels: 8, title: "카워드 알림을 받으려면\n로그인이 필요해요.", subTitle: "로그인 후 간편하게 공지사항 키워드\n알림을 받아보세요!", titleColor: .appColor(.neutral700), subTitleColor: .appColor(.gray)).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let myKeywordCollectionView = MyKeywordCollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    
    private let recommendedKeywordCollectionView = RecommendedKeywordCollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textFieldValueChanged), for: .allEditingEvents)
        addKeywordButton.addTarget(self, action: #selector(tapAddKeywordButton), for: .touchUpInside)
        keywordNotificationSwtich.addTarget(self, action: #selector(changeNotificationKeywordSwitch), for: .valueChanged)
        configureView()
        hideKeyboardWhenTappedAround()
        bind()
        textField.delegate = self
        setNavigationTitle(title: "키워드 관리")
        setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.getMyKeyword)
    }

    // MARK: - Initialization
    
    init(viewModel: ManageNoticeKeywordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case let .updateKeyword(keywords):
                self.updateMyKeywords(keywords: keywords)
            case .showLoginModal:
                self.keywordNotificationSwtich.isOn = false
                self.keywordNotificationSwtich.isEnabled = true
                self.present(self.keywordLoginModalViewController.self, animated: true, completion: nil)
            case let .updateSwitch(isOn):
                self.keywordNotificationSwtich.isOn = isOn
                self.keywordNotificationSwtich.isEnabled = true
            case let .updateRecommendedKeyword(keywords):
                self.updateRecommendedKeywords(keywords: keywords)
            case let .keywordIsIllegal(illegalType):
                self.conductAddKeywordIllegalType(illegalType: illegalType)
            }
        }.store(in: &subscriptions)
        
        myKeywordCollectionView.tapDeleteButtonPublisher
            .sink { [weak self] keyword in
            self?.inputSubject.send(.deleteKeyword(keyword: keyword))
        }.store(in: &subscriptions)
        
        myKeywordCollectionView.myKeywordsContentsSizePublisher.sink { [weak self] height in
            DispatchQueue.main.async {
                self?.myKeywordCollectionView.snp.updateConstraints {
                    $0.height.equalTo(height + 24)
                }
            }
        }.store(in: &subscriptions)
        
        recommendedKeywordCollectionView.recommendedKeywordPublisher.sink { [weak self] keyword in
            self?.inputSubject.send(.addKeyword(keyword: keyword, isRecommended: true))
        }.store(in: &subscriptions)
        
        keywordLoginModalViewController.loginButtonPublisher.sink { [weak self] in
            let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
            loginViewController.title = "로그인"
            self?.navigationController?.pushViewController(loginViewController, animated: true)
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.loginPopupKeyword, .click, "로그인하기"))
        }.store(in: &subscriptions)
        
        keywordLoginModalViewController.cancelButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.loginPopupKeyword, .click, "닫기"))
        }.store(in: &subscriptions)
    }
}

extension ManageNoticeKeywordViewController {
    @objc private func textFieldValueChanged(sender: UITextField) {
        if sender.isEditing {
            textField.layer.borderColor = UIColor.appColor(.primary400).cgColor
            textField.layer.borderWidth = 1
            addKeywordButton.backgroundColor = .appColor(.primary500)
            addKeywordButton.setTitleColor(.appColor(.neutral0), for: .normal)
        }
        else {
            textField.layer.borderWidth = 0
            addKeywordButton.backgroundColor = .appColor(.neutral300)
            addKeywordButton.setTitleColor(.appColor(.neutral600), for: .normal)
        }
    }
    
    @objc private func tapAddKeywordButton() {
        if let text = textField.text {
            inputSubject.send(.addKeyword(keyword: text, isRecommended: false))
            textField.text = ""
            textField.resignFirstResponder()
        }
    }
    
    @objc private func changeNotificationKeywordSwitch(sender: UISwitch) {
        inputSubject.send(.changeNotification(isOn: sender.isOn))
        sender.isEnabled = false
    }
    
    private func updateMyKeywords(keywords: [NoticeKeywordDTO]) {
        myKeywordCollectionView.updateMyKeywords(keywords: keywords)
    }
    
    private func updateRecommendedKeywords(keywords: [String]) {
        recommendedKeywordCollectionView.updateRecommendedKeywords(keywords: keywords)
    }
    
    private func conductAddKeywordIllegalType(illegalType: String) {
        showToast(message: illegalType, success: false)
    }
 
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.text = ""
            inputSubject.send(.addKeyword(keyword: text, isRecommended: false))
        }
        return true
    }
}

extension ManageNoticeKeywordViewController {
    private func setUpLayouts() {
        [navigationBarWrappedView, myKeywordGuideLabel, numberOfKeywordLabel, addKeywordDescriptionLabel, addKeywordButton, textField, myKeywordCollectionView ,separatorView, recommendedKeywordCollectionView, keywordNotificationGuideLabel, keywordNotificationLabel, keywordNotificationDescriptionLabel, keywordNotificationSwtich, recommendedKeywordGuideLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        myKeywordGuideLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(29)
        }
        
        numberOfKeywordLabel.snp.makeConstraints {
            $0.leading.equalTo(myKeywordGuideLabel.snp.trailing)
            $0.top.equalTo(myKeywordGuideLabel)
        }
        
        addKeywordDescriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(myKeywordGuideLabel)
            $0.top.equalTo(myKeywordGuideLabel.snp.bottom)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(addKeywordDescriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(addKeywordDescriptionLabel)
            $0.height.equalTo(38)
            $0.trailing.equalTo(addKeywordButton.snp.leading).offset(-8)
        }
        
        addKeywordButton.snp.makeConstraints {
            $0.top.equalTo(textField)
            $0.trailing.equalToSuperview().inset(36)
            $0.height.equalTo(38)
            $0.width.equalTo(47)
        }
        
        myKeywordCollectionView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(recommendedKeywordCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
        
        keywordNotificationGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        
        keywordNotificationLabel.snp.makeConstraints {
            $0.top.equalTo(keywordNotificationGuideLabel.snp.bottom).offset(32)
            $0.leading.equalTo(keywordNotificationGuideLabel)
            $0.height.equalTo(26)
        }
        
        keywordNotificationDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(keywordNotificationLabel.snp.bottom)
            $0.leading.equalTo(keywordNotificationLabel)
            $0.height.equalTo(19)
        }
        
        keywordNotificationSwtich.snp.makeConstraints {
            $0.top.equalTo(keywordNotificationLabel)
            $0.trailing.equalToSuperview().inset(25)
            $0.width.equalTo(40)
            $0.height.equalTo(16)
        }
        
        recommendedKeywordGuideLabel.snp.makeConstraints {
            $0.top.equalTo(myKeywordCollectionView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(26)
        }
        
        recommendedKeywordCollectionView.snp.makeConstraints {
            $0.top.equalTo(recommendedKeywordGuideLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(86)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}


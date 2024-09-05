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

final class ManageNoticeKeyWordViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: ManageNoticeKeyWordViewModel
    private let inputSubject: PassthroughSubject<ManageNoticeKeyWordViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let navigationTitle = UILabel().then {
        $0.text = "키워드 관리"
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .arrowBack), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    
    private let myKeyWordGuideLabel = UILabel().then {
        $0.text = "내 키워드"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let numberOfKeyWordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
    }
    
    private let addKeyWordDescriptionLabel = UILabel().then {
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
    
    private let addKeyWordButton = UIButton().then {
        $0.setTitle("추가", for: .normal)
        $0.titleLabel?.font = .appFont(.pretendardMedium, size: 13)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.backgroundColor = .appColor(.neutral300)
        $0.layer.cornerRadius = 4
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let keyWordNotificationGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.text = "키워드 알림"
    }
    
    private let keyWordNotificationLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.text = "키워드 알림받기"
    }
    
    private let keyWordNotificationDescriptionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.text = "키워드가 포함된 게시물의 알림을 받을 수 있습니다."
    }
    
    private let keyWordNotificationSwtich = UISwitch().then {
        $0.preferredStyle = .automatic
    }
    
    private let recommendedKeyWordGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "추천 키워드"
    }
    
    private let keyWordLoginModalViewController = KeyWordLoginModalViewController(width: 301, height: 230, paddingBetweenLabels: 8).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let myKeyWordCollectionView = MyKeyWordCollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    
    private let recommendedKeyWordCollectionView = RecommendedKeyWordCollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldValueChanged), for: .allEditingEvents)
        addKeyWordButton.addTarget(self, action: #selector(tapAddKeyWordButton), for: .touchUpInside)
        keyWordNotificationSwtich.addTarget(self, action: #selector(changeNotificationKeyWordSwitch), for: .valueChanged)
        configureView()
        hideKeyboardWhenTappedAround()
        bind()
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        inputSubject.send(.getMyKeyWord)
        inputSubject.send(.fetchSubscription)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Initialization
    
    init(viewModel: ManageNoticeKeyWordViewModel) {
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
            case let .updateKeyWord(keyWords):
                self.updateMyKeyWords(keyWords: keyWords)
            case .showLoginModal:
                self.present(self.keyWordLoginModalViewController.self, animated: true, completion: nil)
                self.keyWordNotificationSwtich.isOn = false
            case let .updateSwitch(isOn):
                self.keyWordNotificationSwtich.isOn = isOn
            case let .updateRecommendedKeyWord(keyWords):
                self.updateRecommendedKeyWords(keyWords: keyWords)
            case let .keyWordIsIllegal(illegalType):
                var message = ""
                switch illegalType {
                case .exceedNumber: message = "키워드는 최대 10개까지 추가할 수 있습니다."
                case .isDuplicated: message = "이미 같은 키워드가 존재합니다."
                case .isNotCharPredicate: message = "키워드는 2글자에서 10글자 사이어야 합니다."
                }
                self.conductAddKeyWordIllegalType(illegalType: message)
            }
        }.store(in: &subscriptions)
        
        myKeyWordCollectionView.tapDeleteButtonPublisher
            .sink { [weak self] keyWord in
                print(keyWord)
            self?.inputSubject.send(.deleteKeyWord(keyWord: keyWord))
        }.store(in: &subscriptions)
        
        myKeyWordCollectionView.myKeyWordsContentsSizePublisher.sink { [weak self] height in
            self?.myKeyWordCollectionView.snp.updateConstraints {
                $0.height.equalTo(height + 24)
            }
        }.store(in: &subscriptions)
        
        recommendedKeyWordCollectionView.recommendedKeyWordPublisher.sink { [weak self] keyWord in
            self?.inputSubject.send(.addKeyWord(keyWord: keyWord))
        }.store(in: &subscriptions)
        
        keyWordLoginModalViewController.loginButtonPublisher.sink { [weak self] in
            let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
            loginViewController.title = "로그인"
            self?.navigationController?.pushViewController(loginViewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension ManageNoticeKeyWordViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func textFieldValueChanged(sender: UITextField) {
        if sender.isEditing {
            textField.layer.borderColor = UIColor.appColor(.primary400).cgColor
            textField.layer.borderWidth = 1
            addKeyWordButton.backgroundColor = .appColor(.primary500)
            addKeyWordButton.setTitleColor(.appColor(.neutral0), for: .normal)
        }
        else {
            textField.layer.borderWidth = 0
            addKeyWordButton.backgroundColor = .appColor(.neutral300)
            addKeyWordButton.setTitleColor(.appColor(.neutral600), for: .normal)
        }
    }
    
    @objc private func tapAddKeyWordButton() {
        if let text = textField.text {
            inputSubject.send(.addKeyWord(keyWord: text))
            textField.text = ""
            textField.resignFirstResponder()
        }
    }
    
    @objc private func changeNotificationKeyWordSwitch(sender: UISwitch) {
        inputSubject.send(.changeNotification(isOn: sender.isOn))
    }
    
    private func updateMyKeyWords(keyWords: [NoticeKeyWordDTO]) {
        myKeyWordCollectionView.updateMyKeyWords(keyWords: keyWords)
    }
    
    private func updateRecommendedKeyWords(keyWords: [String]) {
        recommendedKeyWordCollectionView.updateRecommendedKeyWords(keyWords: keyWords)
    }
    
    private func conductAddKeyWordIllegalType(illegalType: String) {
        showToast(message: illegalType, success: false)
    }
 
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            inputSubject.send(.addKeyWord(keyWord: text))
        }
        return true
    }
}

extension ManageNoticeKeyWordViewController {
    private func setUpLayouts() {
        [backButton, navigationTitle, myKeyWordGuideLabel, numberOfKeyWordLabel, addKeyWordDescriptionLabel, addKeyWordButton, textField, myKeyWordCollectionView ,separatorView, recommendedKeyWordCollectionView, keyWordNotificationGuideLabel, keyWordNotificationLabel, keyWordNotificationDescriptionLabel, keyWordNotificationSwtich, recommendedKeyWordGuideLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationTitle.snp.makeConstraints {
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        myKeyWordGuideLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(26.5)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(29)
        }
        
        numberOfKeyWordLabel.snp.makeConstraints {
            $0.leading.equalTo(myKeyWordGuideLabel.snp.trailing)
            $0.top.equalTo(myKeyWordGuideLabel)
        }
        
        addKeyWordDescriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(myKeyWordGuideLabel)
            $0.top.equalTo(myKeyWordGuideLabel.snp.bottom)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(addKeyWordDescriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(addKeyWordDescriptionLabel)
            $0.height.equalTo(38)
            $0.trailing.equalTo(addKeyWordButton.snp.leading).offset(-8)
        }
        
        addKeyWordButton.snp.makeConstraints {
            $0.top.equalTo(textField)
            $0.trailing.equalToSuperview().inset(36)
            $0.height.equalTo(38)
            $0.width.equalTo(47)
        }
        
        myKeyWordCollectionView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(recommendedKeyWordCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
        
        keyWordNotificationGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        
        keyWordNotificationLabel.snp.makeConstraints {
            $0.top.equalTo(keyWordNotificationGuideLabel.snp.bottom).offset(32)
            $0.leading.equalTo(keyWordNotificationGuideLabel)
            $0.height.equalTo(26)
        }
        
        keyWordNotificationDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(keyWordNotificationLabel.snp.bottom)
            $0.leading.equalTo(keyWordNotificationLabel)
            $0.height.equalTo(19)
        }
        
        keyWordNotificationSwtich.snp.makeConstraints {
            $0.top.equalTo(keyWordNotificationLabel)
            $0.trailing.equalToSuperview().inset(25)
            $0.width.equalTo(40)
            $0.height.equalTo(16)
        }
        
        recommendedKeyWordGuideLabel.snp.makeConstraints {
            $0.top.equalTo(myKeyWordCollectionView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(26)
        }
        
        recommendedKeyWordCollectionView.snp.makeConstraints {
            $0.top.equalTo(recommendedKeyWordGuideLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(86)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .white
    }
}


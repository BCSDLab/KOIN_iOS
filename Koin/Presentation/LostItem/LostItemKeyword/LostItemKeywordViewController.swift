//
//  LostItemKeywordViewController.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import UIKit
import Combine
import SnapKit

final class LostItemKeywordViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: LostItemKeywordViewModel
    private let inputSubject = PassthroughSubject<LostItemKeywordViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let myKeywordTitleLabel = UILabel()
    private let myKeywordCountLabel = UILabel()
    private let myKeywordDescriptionLabel = UILabel()
    private let myKeywordTextField = UITextField()
    private let myKeywordAddButton = UIButton()
    private let myKeywordCollectionView = LostItemKeywordLeftAlignedCollectionView(action: .delete)
    
    private let keywordSuggestionTitleLabel = UILabel()
    private let keywordSuggestionCollectionView = LostItemKeywordLeftAlignedCollectionView(action: .add)
    
    private let middleSeparatorView = UIView()
    
    private let notificationTitleLabel = UILabel()
    private let notificationSubTitleLabel = UILabel()
    private let notificationDescriptionLabel = UILabel()
    private let notificationSwitch = UISwitch()
    
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initializer
    init(viewModel: LostItemKeywordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar(style: .empty)
        view.backgroundColor = .appColor(.neutral0)
        title = "분실물 키워드 관리"
        bind()
        setAddTargets()
        setDelegates()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.viewWillAppear)
    }
}

extension LostItemKeywordViewController {
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .showLoginModal:
                notificationSwitch.setOn(false, animated: true)
                showLoginModal()
            case let .updateKeywordSuggestion(keywords):
                keywordSuggestionCollectionView.configure(keywords: keywords)
            case let .updateMyKeyword(keywords):
                updateMyKeywordCountLabel(keywords.count)
                myKeywordCollectionView.configure(keywords: keywords)
            case let .updateSubscription(isOn):
                notificationSwitch.isOn = isOn
            case let .updateCurrentCount(count):
                updateMyKeywordCountLabel(count)
            case let .appendMyKeyword(keyword):
                myKeywordCollectionView.append(keyword: keyword)
            case let .removeKeywordSuggestion(keyword):
                keywordSuggestionCollectionView.remove(keyword: keyword)
            case .showToastExceedCount:
                showToast(message: "키워드는 최대 10개까지 추가할 수 있습니다.", success: false)
            case .showToastKeywordLength:
                showToast(message: "키워드는 2글자에서 10글자 사이여야 합니다.", success: false)
            }
        }.store(in: &subscriptions)
        
        myKeywordCollectionView.didLayoutSubviewsPublisher.sink { [weak self] height in
            guard let self else { return }
            let inset: CGFloat = 12 * 2
            updateHeight(view: myKeywordCollectionView, height: height + inset)
        }.store(in: &subscriptions)
        
        keywordSuggestionCollectionView.didLayoutSubviewsPublisher.sink { [weak self] height in
            guard let self else { return }
            updateHeight(view: keywordSuggestionCollectionView, height: height)
        }.store(in: &subscriptions)
        
        myKeywordCollectionView.didTapItemPublisher.sink { [weak self] keyword in
            self?.inputSubject.send(.deleteKeyword(keyword))
            self?.myKeywordCollectionView.remove(keyword: keyword)
        }.store(in: &subscriptions)
        
        keywordSuggestionCollectionView.didTapItemPublisher.sink { [weak self] keyword in
            self?.inputSubject.send(.subscribeKeyword(keyword))
        }.store(in: &subscriptions)
    }
    
    private func updateHeight(view: UIView, height: CGFloat) {
        view.snp.updateConstraints {
            $0.height.equalTo(height)
        }
        UIView.animate(withDuration: 0.2, delay: .zero, options: [.transitionCrossDissolve]) { [weak view] in
            view?.superview?.setNeedsLayout()
            view?.superview?.layoutIfNeeded()
        }
    }
}

extension LostItemKeywordViewController {
    
    private func setAddTargets() {
        myKeywordAddButton.addTarget(self, action: #selector(myKeywordAddButtonTapped), for: .touchUpInside)
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchTapped), for: .valueChanged)
    }
    
    @objc private func myKeywordAddButtonTapped() {
        if let text = myKeywordTextField.text {
            inputSubject.send(.subscribeKeyword(text))
        }
    }
    
    @objc private func notificationSwitchTapped() {
        inputSubject.send(.notificationSwitchTapped(isOn: notificationSwitch.isOn))
    }
}

extension LostItemKeywordViewController {
    
    private func setDelegates() {
        myKeywordTextField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        myKeywordTextField.layer.borderColor = UIColor.appColor(.primary400).cgColor
        myKeywordAddButton.backgroundColor = .appColor(.primary500)
        changeButtonForegroundColor(to: .appColor(.neutral0))
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        myKeywordTextField.layer.borderColor = UIColor.clear.cgColor
        myKeywordAddButton.backgroundColor = .appColor(.neutral300)
        changeButtonForegroundColor(to: .appColor(.neutral600))
    }
    
    private func changeButtonForegroundColor(to color: UIColor) {
        if let currentAttributedTitle = myKeywordAddButton.currentAttributedTitle {
            let mutableAttributedTitle = NSMutableAttributedString(attributedString: currentAttributedTitle)
            let fullRange = NSRange(location: 0, length: mutableAttributedTitle.length)
            mutableAttributedTitle.setAttributes(
                [
                    .foregroundColor : color,
                    .font : UIFont.appFont(.pretendardMedium, size: 13)
                ],
                range: fullRange)
            myKeywordAddButton.setAttributedTitle(mutableAttributedTitle, for: .normal)
        }
    }
}

extension LostItemKeywordViewController {
    
    private func showLoginModal() {
        let onRightButtonTapped: ()->Void = { [weak self] in
            self?.navigateToLogin()
        }
        let viewController = ModalViewControllerB(
            onRightButtonTapped: onRightButtonTapped,
            width: 301,
            height: 228,
            paddingBetweenLabels: 16,
            title: "키워드 알림을 받으려면\n로그인이 필요해요.",
            subTitle: "로그인 후 간편하게 분실물 키워드\n알림을 받아보세요!",
            titleColor: .appColor(.neutral800),
            subTitleColor: .appColor(.gray)
        )
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(viewController, animated: true)
    }
    
    private func updateMyKeywordCountLabel(_ count: Int) {
        myKeywordCountLabel.text = "\(count)/\(viewModel.maxCount)"
    }
}

extension LostItemKeywordViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    private func setUpStyles() {
        // MARK: - 내 키워드
        myKeywordTitleLabel.do {
            $0.text = "내 키워드"
            $0.font = .appFont(.pretendardSemiBold, size: 18)
            $0.textColor = .appColor(.neutral800)
        }
        myKeywordCountLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral500)
        }
        myKeywordDescriptionLabel.do {
            $0.text = "키워드는 최대 10개까지 추가 가능합니다."
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }
        myKeywordTextField.do {
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            $0.leftViewMode = .always
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            $0.rightViewMode = .always
            
            $0.attributedPlaceholder = NSAttributedString(
                string: "잃어버린 물건을 입력해 주세요.",
                attributes: [
                    .font : UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor : UIColor.appColor(.gray)
                ]
            )
            $0.textColor = .appColor(.neutral800)
            $0.font = .appFont(.pretendardRegular, size: 14)
            
            $0.backgroundColor = .appColor(.neutral100)
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.clear.cgColor
        }
        myKeywordAddButton.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "추가",
                    attributes: [
                        .font : UIFont.appFont(.pretendardMedium, size: 13),
                        .foregroundColor : UIColor.appColor(.neutral600)
                    ]),
                for: .normal)
            $0.backgroundColor = .appColor(.neutral300)
            $0.layer.cornerRadius = 4
        }
        myKeywordCollectionView.do {
            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        // MARK: - 추천 키워드
        keywordSuggestionTitleLabel.do {
            $0.text = "추천 키워드"
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textColor = .appColor(.neutral800)
        }
        middleSeparatorView.do {
            $0.backgroundColor = .appColor(.neutral100)
        }
        // MARK: - 키워드 알림
        notificationTitleLabel.do {
            $0.text = "키워드 알림"
            $0.font = .appFont(.pretendardSemiBold, size: 18)
            $0.textColor = .appColor(.neutral800)
        }
        notificationSubTitleLabel.do {
            $0.text = "분실물 키워드 알림 받기"
            $0.textColor = .black
            $0.font = .appFont(.pretendardMedium, size: 16)
        }
        notificationDescriptionLabel.do {
            $0.text = "키워드가 포함된 분실물 게시글의 알림을 받습니다."
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }
        notificationSwitch.do {
            $0.onTintColor = .appColor(.primary500)
        }
        bottomSeparatorView.do {
            $0.backgroundColor = .appColor(.neutral100)
        }
    }
    
    private func setUpLayouts() {
        [myKeywordTitleLabel, myKeywordCountLabel, myKeywordDescriptionLabel, myKeywordTextField, myKeywordAddButton, myKeywordCollectionView,
         keywordSuggestionTitleLabel, keywordSuggestionCollectionView, middleSeparatorView,
         notificationTitleLabel, notificationSubTitleLabel, notificationDescriptionLabel, notificationSwitch, bottomSeparatorView].forEach {
            contentView.addSubview($0)
        }
        [contentView].forEach {
            scrollView.addSubview($0)
        }
        [scrollView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // MARK: - 내 키워드
        myKeywordTitleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        myKeywordCountLabel.snp.makeConstraints {
            $0.leading.equalTo(myKeywordTitleLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(myKeywordTitleLabel)
        }
        myKeywordDescriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(myKeywordTitleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
        }
        myKeywordTextField.snp.makeConstraints {
            $0.height.equalTo(38)
            $0.top.equalTo(myKeywordDescriptionLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(myKeywordAddButton.snp.leading).offset(-8)
        }
        myKeywordAddButton.snp.makeConstraints {
            $0.top.bottom.equalTo(myKeywordTextField)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(47)
        }
        myKeywordCollectionView.snp.makeConstraints {
            $0.height.equalTo(0)
            $0.top.equalTo(myKeywordTextField.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        // MARK: - 추천 키워드
        keywordSuggestionTitleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.top.equalTo(myKeywordCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        keywordSuggestionCollectionView.snp.makeConstraints {
            $0.height.equalTo(0)
            $0.top.equalTo(keywordSuggestionTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        middleSeparatorView.snp.makeConstraints {
            $0.height.equalTo(6)
            $0.top.equalTo(keywordSuggestionCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        // MARK: - 키워드 알림
        notificationTitleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(middleSeparatorView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        notificationSubTitleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.top.equalTo(notificationTitleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
        }
        notificationDescriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(notificationSubTitleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(notificationSwitch.snp.leading).offset(-16)
        }
        notificationSwitch.snp.makeConstraints {
            $0.centerY.equalTo(notificationSubTitleLabel.snp.bottom)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        bottomSeparatorView.snp.makeConstraints {
            $0.top.equalTo(notificationDescriptionLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

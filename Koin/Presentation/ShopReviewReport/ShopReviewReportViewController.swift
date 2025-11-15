//
//  ShopReviewReportViewController.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine
import UIKit
import SnapKit

final class ShopReviewReportViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ShopReviewReportViewModel
    private let inputSubject: PassthroughSubject<ShopReviewReportViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    let reviewInfoPublisher = PassthroughSubject<(Int, Int), Never>()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.delaysContentTouches = false
    }
    
    private let reportReasonLabel = UILabel().then {
        $0.text = "신고 이유를 선택해주세요."
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
    }
    
    private let reportGuideLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textColor = UIColor.appColor(.gray)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.setLineHeight(lineHeight: 1.4, text: "접수된 신고는 관계자 확인 하에 블라인드 처리됩니다.\n블라인드 처리까지 시간이 소요될 수 있습니다.")
    }
    
    private let nonSubjectReportView = ReportDetailView(frame: .zero, title: "주제에 맞지 않음", description: "해당 음식점과 관련 없는 리뷰입니다.")
    
    private let spamReportView = ReportDetailView(frame: .zero, title: "스팸", description: "광고가 포함된 리뷰입니다.")
    
    private let curseReportView = ReportDetailView(frame: .zero, title: "욕설", description: "욕설, 성적인 언어, 비방하는 글이 포함된 리뷰입니다.")
    
    private let personalInfoReportView = ReportDetailView(frame: .zero, title: "개인정보", description: "개인정보가 포함된 리뷰입니다.")
    
    private let etcContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }
    
    private let etcCheckButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .circle), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let etcLabel = UILabel().then {
        $0.text = "기타"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let etcTextCountLabel = UILabel().then {
        $0.text = "0/150"
        $0.textColor = UIColor.appColor(.gray)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    
    private let etcReportPlaceholderLabel = UILabel().then {
        $0.text = "신고 사유를 입력해주세요."
        $0.textColor = UIColor.appColor(.neutral400)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.numberOfLines = 0
    }

    private let etcReportTextView = UITextView().then {
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1.0
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.textContainer.lineFragmentPadding = 0
    }
    
    private let reportButton = UIButton().then {
        $0.setTitle("신고하기", for: .normal)
        $0.titleLabel?.textColor = UIColor.appColor(.neutral0)
        $0.isEnabled = false
        $0.backgroundColor = UIColor.appColor(.neutral300)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.02, x: 0, y: 1, blur: 1, spread: 0)
    }
    
    // MARK: - Initialize
    
    init(viewModel: ShopReviewReportViewModel) {
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
        navigationItem.title = "리뷰 신고하기"
        bind()
        configureView()
        hideKeyboardWhenTappedAround()
        setAddTarget()
        setDelegate()
        setupKeyboardNotifications()
        setupEtcGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showToast(message):
                self?.showToastMessage(message: message, intent: .neutral, bottomInset: 70)
            case let .sendReviewInfo(reviewId, shopId):
                self?.reviewInfoPublisher.send((reviewId, shopId))
                self?.navigationController?.popViewController(animated: true)
            }
        }.store(in: &subscriptions)
        
        let reportViews = [
            nonSubjectReportView.checkButtonPublisher,
            spamReportView.checkButtonPublisher,
            curseReportView.checkButtonPublisher,
            personalInfoReportView.checkButtonPublisher
        ]
        
        for publisher in reportViews {
            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.updateReportButtonState()
                }
                .store(in: &subscriptions)
        }
    }
    
    private func setAddTarget() {
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    private func setDelegate() {
        etcReportTextView.delegate = self
    }
    
    private func setupEtcGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(etcContainerTapped))
        etcContainerView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - UITextViewDelegate

extension ShopReviewReportViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.count <= 150
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        etcTextCountLabel.text = "\(characterCount)/150"
        etcReportPlaceholderLabel.isHidden = !textView.text.isEmpty
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ShopReviewReportViewController {
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - view.safeAreaInsets.bottom + 100, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            let textViewFrame = self.etcReportTextView.convert(self.etcReportTextView.bounds, to: self.view)
            let visibleHeight = self.view.frame.height - keyboardHeight
            
            if textViewFrame.maxY > visibleHeight {
                let scrollOffset = textViewFrame.maxY - visibleHeight + 20
                let newOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y + scrollOffset)
                
                self.scrollView.setContentOffset(newOffset, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.scrollView.contentInset = .zero
            self?.scrollView.scrollIndicatorInsets = .zero
        }
    }
}

extension ShopReviewReportViewController {
    
    private func updateReportButtonState() {
        let anySelectedInReportViews = [nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView].contains { $0.isCheckButtonSelected() }
        let anySelectedInViewController = etcCheckButton.isSelected
        
        let anySelected = anySelectedInReportViews || anySelectedInViewController
        
        reportButton.isEnabled = anySelected
        reportButton.backgroundColor = anySelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral300)
    }
    
    @objc private func etcContainerTapped() {
        etcCheckButton.isSelected.toggle()
        etcCheckButton.setImage(etcCheckButton.isSelected ? UIImage.appImage(asset: .filledCircle)?.withTintColor(UIColor.appColor(.new500), renderingMode: .alwaysOriginal) : UIImage.appImage(asset: .circle), for: .normal)
        etcTextCountLabel.textColor = etcCheckButton.isSelected ? UIColor.appColor(.new500) : UIColor.appColor(.gray)
        etcReportTextView.isEditable = etcCheckButton.isSelected
        
        if etcCheckButton.isSelected {
            etcReportTextView.becomeFirstResponder()
        } else {
            etcReportTextView.resignFirstResponder()
            etcReportTextView.text = ""
            etcReportPlaceholderLabel.isHidden = false
            etcTextCountLabel.text = "0/150"
        }
        
        updateReportButtonState()
    }
    
    @objc private func reportButtonTapped() {
        var reports: [Report] = []
        let reportViews = [nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView]
        
        for reportView in reportViews {
            if reportView.isCheckButtonSelected() {
                let reportInfo = reportView.getReportInfo()
                let report = Report(title: reportInfo.title, content: reportInfo.content)
                reports.append(report)
            }
        }
        if etcCheckButton.isSelected, let etcText = etcReportTextView.text {
            let report = Report(title: "기타", content: etcText)
            reports.append(report)
        }
    
        let requestModel = ReportReviewRequest(reports: reports)
        inputSubject.send(.reportReview(requestModel))
    }
}

// MARK: - UI Function

extension ShopReviewReportViewController {
    
    private func setUpLayouts() {
        view.addSubview(scrollView)
        
        [reportReasonLabel, reportGuideLabel, nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView, etcContainerView, etcReportTextView].forEach {
            scrollView.addSubview($0)
        }
        
        [etcCheckButton, etcLabel, etcTextCountLabel].forEach {
            etcContainerView.addSubview($0)
        }
        
        etcReportTextView.addSubview(etcReportPlaceholderLabel)
        view.addSubview(reportButton)
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom).offset(-100)
        }
        
        reportReasonLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(24)
            $0.leading.equalTo(view.snp.leading).offset(24)
        }
        
        reportGuideLabel.snp.makeConstraints {
            $0.top.equalTo(reportReasonLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(24)
        }
        
        nonSubjectReportView.snp.makeConstraints {
            $0.top.equalTo(reportGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(20)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
            $0.height.equalTo(76)
        }
        
        spamReportView.snp.makeConstraints {
            $0.top.equalTo(nonSubjectReportView.snp.bottom)
            $0.leading.equalTo(view.snp.leading).offset(20)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
            $0.height.equalTo(76)
        }
        
        curseReportView.snp.makeConstraints {
            $0.top.equalTo(spamReportView.snp.bottom)
            $0.leading.equalTo(view.snp.leading).offset(20)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
            $0.height.equalTo(76)
        }
        
        personalInfoReportView.snp.makeConstraints {
            $0.top.equalTo(curseReportView.snp.bottom)
            $0.leading.equalTo(view.snp.leading).offset(20)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
            $0.height.equalTo(76)
        }
        
        etcContainerView.snp.makeConstraints {
            $0.top.equalTo(personalInfoReportView.snp.bottom).offset(19)
            $0.leading.equalTo(view.snp.leading).offset(20)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
            $0.height.equalTo(16)
        }
        
        etcCheckButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(16)
        }
        
        etcLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(etcCheckButton.snp.trailing).offset(16)
        }
        
        etcTextCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
        }
        
        etcReportTextView.snp.makeConstraints {
            $0.top.equalTo(etcContainerView.snp.bottom).offset(13)
            $0.leading.equalTo(view.snp.leading).offset(28)
            $0.trailing.equalTo(view.snp.trailing).offset(-20)
            $0.height.greaterThanOrEqualTo(42)
            $0.bottom.equalTo(scrollView.snp.bottom).offset(-20)
        }
        
        etcReportPlaceholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        reportButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(46)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}

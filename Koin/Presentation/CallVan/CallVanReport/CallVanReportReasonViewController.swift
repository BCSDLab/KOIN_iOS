//
//  CallVanReportReasonViewController.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanReportReasonViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CallVanReportViewModel
    private let inputSubject = PassthroughSubject<CallVanReportViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let customReasonPlaceholder = "신고 사유를 입력해주세요."
    private let maximumReasonLength = 150
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let buttonsStackView = UIStackView()
    private let reasonButtons: [CallVanReportReasonButton] = {
        var reasonButtons: [CallVanReportReasonButton] = []
        let reasonCodes: [CallVanReportRequestReasonCode] = [.noShow, .nonPayment, .profanity]
        for reasonCode in reasonCodes {
            reasonButtons.append(CallVanReportReasonButton(title: reasonCode.title, description: reasonCode.description))
        }
        return reasonButtons
    }()
    private let separatorViews = [
        UIView(),
        UIView(),
        UIView()
    ]
    private let customReasonButton = CallVanReportCustomReasonButton()
    private let numberOfTextsLabel = UILabel()
    private let customReasonTextViewWrapperView = UIView()
    private let customReasonTextView = UITextView()
    private let bottomSeparatorView = UIView()
    private let nextButton = UIButton()
    
    // MARK: - Initialzier
    init(viewModel: CallVanReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "신고하기"
        configureView()
        configureNavigationBar(style: .empty)
        setDelegate()
        setAddTargets()
        addGesture()
        addObserver()
        bind()
        
    }
}

extension CallVanReportReasonViewController {
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .validateNextButton(validation):
                updateNextButton(validation)
            }
        }.store(in: &subscriptions)
    }
    
}

extension CallVanReportReasonViewController {
    
    private func setDelegate() {
        customReasonTextView.delegate = self
    }
    
    private func setAddTargets() {
        reasonButtons.forEach {
            $0.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        }
        customReasonButton.addTarget(self, action: #selector(customReasonButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addObserver() {
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
}

extension CallVanReportReasonViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.appColor(.gray) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
        setCustomReasonButtonSelected()
        updateTextCount()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentText = textView.textColor == UIColor.appColor(.gray) ? "" : textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputSubject.send(.updateCustomReason(currentText))
        updateTextCount()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = customReasonPlaceholder
            textView.textColor = UIColor.appColor(.gray)
            updateTextCount()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.textColor == UIColor.appColor(.gray) ? "" : (textView.text ?? "")
        
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maximumReasonLength
    }
}

extension CallVanReportReasonViewController {
    
    // MARK: - Button
    @objc private func reasonButtonTapped(_ sender: CallVanReportReasonButton) {
        setReasonButtonSelected(sender)
        dismissKeyboard()
    }
    
    @objc private func customReasonButtonTapped() {
        setCustomReasonButtonSelected()
        
        customReasonTextView.becomeFirstResponder()
    }
    
    @objc private func nextButtonTapped() {
        let viewController = CallVanReportEvidenceViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func setReasonButtonSelected(_ sender: CallVanReportReasonButton) {
        reasonButtons.forEach { button in
            button.isSelected = button === sender
        }
        customReasonButton.isSelected = false
        
        if let reasonCode = CallVanReportRequestReasonCode(title: sender.title) {
            inputSubject.send(.updateReasonCode(reasonCode))
        } else {
            print("\(#function) failed")
        }
    }
    
    private func setCustomReasonButtonSelected() {
        reasonButtons.forEach { button in
            button.isSelected = false
        }
        customReasonButton.isSelected = true
        
        inputSubject.send(.updateReasonCode(.other))
    }
    
    private func updateNextButton(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.backgroundColor = isEnabled ? UIColor.appColor(.new500) : UIColor.appColor(.neutral400)
    }
    
    // MARK: - Count Label
    private func updateTextCount() {
        let textCount = customReasonTextView.textColor == UIColor.appColor(.gray) ? 0 : customReasonTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        numberOfTextsLabel.textColor = textCount == 0 ? UIColor.appColor(.gray) : UIColor.appColor(.new500)
        numberOfTextsLabel.text = "\(textCount)/\(maximumReasonLength)"
    }
    
    // MARK: - ScrollView
    @objc private func keyboardWillShow() {
        bottomSeparatorView.snp.updateConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
        }
        var rect = customReasonTextViewWrapperView.convert(customReasonTextViewWrapperView.bounds, to: scrollView)
        rect.size.height += 12
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @objc private func keyboardWillHide() {
        bottomSeparatorView.snp.updateConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-24)
        }
    }
}

extension CallVanReportReasonViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayOuts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        scrollView.keyboardDismissMode = .interactive
        
        titleLabel.do {
            $0.text = "신고 이유를 선택해주세요."
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        descriptionLabel.do {
            $0.numberOfLines = 0
            let attributedText = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.minimumLineHeight = 14 * 1.6
                paragraphStyle.maximumLineHeight = 14 * 1.6
                return NSAttributedString(
                    string: "신고가 접수되면 운영정책에 따라 검토 후 주변 기능이 제한될 수 있습니다. 본 서비스는 비용 정산에 직접 관여하지 않습니다.",
                    attributes: [
                        .font : UIFont.appFont(.pretendardRegular, size: 14),
                        .paragraphStyle : paragraphStyle,
                        .foregroundColor : UIColor.appColor(.neutral500)
                    ]
                )
            }()
            $0.attributedText = attributedText
        }
        buttonsStackView.do {
            $0.axis = .vertical
            $0.spacing = 12
        }
        separatorViews.forEach {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
        numberOfTextsLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.text = "0/150"
            $0.textColor = UIColor.appColor(.gray)
        }
        customReasonTextViewWrapperView.do {
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
        }
        customReasonTextView.do {
            $0.text = customReasonPlaceholder
            $0.textColor = UIColor.appColor(.gray)
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.backgroundColor = .clear
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
        }
        bottomSeparatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        nextButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "다음",
                attributes: [
                    .font : UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.neutral400)
            $0.layer.cornerRadius = 8
            $0.layer.applySketchShadow(color: UIColor.black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
            $0.isEnabled = false
        }
    }
    
    private func setUpLayOuts() {
        for index in 0..<3 {
            buttonsStackView.addArrangedSubview(reasonButtons[index])
            buttonsStackView.addArrangedSubview(separatorViews[index])
        }
        buttonsStackView.addArrangedSubview(customReasonButton)
        
        [customReasonTextView].forEach {
            customReasonTextViewWrapperView.addSubview($0)
        }
        
        [titleLabel, descriptionLabel, buttonsStackView, numberOfTextsLabel, customReasonTextViewWrapperView].forEach {
            contentView.addSubview($0)
        }
        [contentView].forEach {
            scrollView.addSubview($0)
        }
        [scrollView, bottomSeparatorView, nextButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomSeparatorView.snp.top)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        separatorViews.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(1)
                $0.width.equalTo(buttonsStackView)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        buttonsStackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        numberOfTextsLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.bottom.equalTo(buttonsStackView)
            $0.trailing.equalTo(buttonsStackView).offset(-13)
        }
        customReasonTextViewWrapperView.snp.makeConstraints {
            $0.top.equalTo(buttonsStackView.snp.bottom).offset(8)
            $0.height.equalTo(134)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().offset(-24)
        }
        customReasonTextView.snp.makeConstraints {
            $0.top.bottom.equalTo(customReasonTextViewWrapperView).inset(12)
            $0.leading.trailing.equalTo(customReasonTextViewWrapperView).inset(16)
        }
        nextButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-24)
        }
    }
}

//
//  ReportLostItemViewController.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import Then
import UIKit

protocol ReportLostItemViewControllerDelegate: AnyObject {
    func updateState(reportedDataId id: Int)
}

final class ReportLostItemViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    private let viewModel: ReportLostItemViewModel
    private let inputSubject: PassthroughSubject<ReportLostItemViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private let textViewPlaceHolder = "신고 사유를 입력해주세요."
    private var previousScrollViewSize = CGSize.zero
    weak var delegate: ReportLostItemViewControllerDelegate?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let reportReasonLabel = UILabel().then {
        $0.text = "신고 이유를 선택해주세요."
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
    }
    
    private let reportGuideLabel = UILabel().then {
        $0.text = "접수된 신고는 관계자 확인 하에 블라인드 처리됩니다.\n블라인드 처리까지 시간이 소요될 수 있습니다."
        $0.numberOfLines = 2
        $0.textColor = UIColor.appColor(.neutral500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let nonSubjectReportView = ReportDetailView(frame: .zero, title: "주제에 맞지 않음", description: "분실물과 관련 없는 글입니다.").then { _ in
    }
    
    private let spamReportView = ReportDetailView(frame: .zero, title: "스팸", description: "광고가 포함된 글입니다.").then { _ in
    }
    
    private let curseReportView = ReportDetailView(frame: .zero, title: "욕설", description: "욕설, 성적인 언어, 비방하는 글이 포함된 글입니다.").then { _ in
    }
    
    private let personalInfoReportView = ReportDetailView(frame: .zero, title: "개인정보", description: "개인정보가 포함된 글입니다.").then { _ in
    }
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .circle), for: .normal)
    }
    
    private let etcLabel = UILabel().then {
        $0.text = "기타"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let textCountLabel = UILabel().then {
        $0.text = "0/150"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private lazy var etcReportTextView = UITextView().then {
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1.0
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.textContainer.lineFragmentPadding = 0
        $0.text = textViewPlaceHolder
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.textColor = UIColor.appColor(.neutral500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let reportButton = DebouncedButton().then {
        $0.setTitle("신고하기", for: .normal)
        $0.setTitleColor(.appColor(.neutral0), for: .normal)
        $0.isEnabled = false
        $0.setTitleColor(.appColor(.neutral800), for: .disabled)
        $0.backgroundColor = UIColor.appColor(.neutral400)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initialization
    
    init(viewModel: ReportLostItemViewModel) {
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
        navigationItem.title = "게시글 신고하기"
        bind()
        configureView()
        hideKeyboardWhenTappedAround()
        etcReportTextView.delegate = self
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        reportButton.throttle(interval: .seconds(3)) { [weak self] in
            self?.reportReview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard previousScrollViewSize != scrollView.bounds.size else { return }
        previousScrollViewSize = scrollView.bounds.size
        if etcReportTextView.isFirstResponder {
            scrollReportInputToVisible(animated: false)
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .showToast(let message, let success):
                self.showToastMessage(message: message, intent: success ? .positive : .negative)
                if success {
                    if let previousViewController = (delegate as? LostItemDataViewController)?.delegate as? UIViewController {
                        navigationController?.popToViewController(previousViewController, animated: true)
                    }
                    delegate?.updateState(reportedDataId: viewModel.lostItemId)
                }
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
    
    
}

extension ReportLostItemViewController {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = ""
            textView.textColor = .appColor(.neutral800)
        }
        scrollReportInputToVisible(animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .appColor(.neutral500)
        }
    }
    
    private func updateReportButtonState() {
        let anySelectedInReportViews = [nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView].contains { $0.isCheckButtonSelected() }
        let anySelectedInViewController = checkButton.isSelected
        
        let anySelected = anySelectedInReportViews || anySelectedInViewController
        
        reportButton.isEnabled = anySelected
        reportButton.backgroundColor = anySelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral400)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.count <= 150
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        textCountLabel.text = "\(characterCount)/150"
        textCountLabel.textColor = .appColor(.new500)

        guard let font = textView.font else { return }

        let lineHeight = font.lineHeight
        let maxHeight = lineHeight * 6 + textView.textContainerInset.top + textView.textContainerInset.bottom

        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = max(46, min(size.height, maxHeight))

        textView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }

        textView.isScrollEnabled = size.height > maxHeight
        view.layoutIfNeeded()
        scrollReportInputToVisible(animated: true)
    }

    private func scrollReportInputToVisible(animated: Bool) {
        let rect = etcReportTextView.convert(etcReportTextView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -8), animated: animated)
    }

    
    @objc private func checkButtonTapped() {
        checkButton.isSelected.toggle()
        
        let image = checkButton.isSelected
            ? UIImage.appImage(asset: .filledCircle)?.withTintColor(.appColor(.new500), renderingMode: .alwaysOriginal)
            : UIImage.appImage(asset: .circle)
        checkButton.setImage(image, for: .normal)
        textCountLabel.textColor = .appColor(checkButton.isSelected ? .new500 : .neutral500)
        etcReportTextView.isEditable = checkButton.isSelected
        
        updateReportButtonState()
    }
    private func reportReview() {
        var reports: [ReportLostItem] = []
        let reportViews = [nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView]
        
        for reportView in reportViews {
            if reportView.isCheckButtonSelected() {
                let reportInfo = reportView.getReportInfo()
                let report = ReportLostItem(title: reportInfo.title, content: reportInfo.content)
                reports.append(report)
            }
        }
        if checkButton.isSelected, var etcText = etcReportTextView.text {
            if etcText == textViewPlaceHolder { etcText = "" }
            let report = ReportLostItem(title: "기타", content: etcText)
            reports.append(report)
        }
    
        let requestModel = ReportLostItemRequest(reports: reports)
        inputSubject.send(.reportLostItemArticle(requestModel))
        inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.itemPostReportConfirm, .click, "신고하기"))
    }
    
}

extension ReportLostItemViewController {
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(reportButton)
        scrollView.addSubview(contentView)
        [reportReasonLabel, reportGuideLabel, nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView, checkButton, etcLabel, textCountLabel, etcReportTextView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).priority(.high)
            make.bottom.lessThanOrEqualTo(reportButton.snp.top).offset(-16)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        reportReasonLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        reportGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(reportReasonLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        nonSubjectReportView.snp.makeConstraints { make in
            make.top.equalTo(reportGuideLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(76)
        }
        spamReportView.snp.makeConstraints { make in
            make.top.equalTo(nonSubjectReportView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(76)
        }
        curseReportView.snp.makeConstraints { make in
            make.top.equalTo(spamReportView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(76)
        }
        personalInfoReportView.snp.makeConstraints { make in
            make.top.equalTo(curseReportView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(76)
        }
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(personalInfoReportView.snp.bottom).offset(19)
            make.leading.equalToSuperview().offset(28)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        etcLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkButton.snp.centerY)
            make.leading.equalTo(checkButton.snp.trailing).offset(16)
        }
        textCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkButton.snp.centerY)
            make.trailing.equalToSuperview().offset(-34)
        }
        etcReportTextView.snp.makeConstraints { make in
            make.top.equalTo(checkButton.snp.bottom).offset(13)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(46)
            make.bottom.equalToSuperview().offset(-24)
        }
        reportButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .appColor(.neutral0)
    }
}


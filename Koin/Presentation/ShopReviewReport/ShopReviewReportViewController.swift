//
//  ShopReviewReportViewController.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine
import Then
import UIKit

final class ShopReviewReportViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    
    private let viewModel: ShopReviewReportViewModel
    private let inputSubject: PassthroughSubject<ShopReviewReportViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView().then { _ in
    }
    
    private let reportReasonLabel = UILabel().then {
        $0.text = "신고 이유를 선택해주세요."
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
    }
    
    private let reportGuideLabel = UILabel().then {
        $0.text = "접수된 신고는 관계자 확인 하에 블라인드 처리됩니다.\n블라인드 처리까지 시간이 소요될 수 있습니다."
        $0.numberOfLines = 2
        $0.textColor = UIColor.appColor(.neutral500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let nonSubjectReportView = ReportDetailView(frame: .zero, title: "주제에 맞지 않음", description: "해당 음식점과 관련 없는 리뷰입니다.").then { _ in
    }
    
    private let spamReportView = ReportDetailView(frame: .zero, title: "스팸", description: "광고가 포함된 리뷰입니다.").then { _ in
    }
    
    private let curseReportView = ReportDetailView(frame: .zero, title: "욕설", description: "욕설, 성적인 언어, 비방하는 글이 포함된 리뷰입니다.").then { _ in
    }
    
    private let personalInfoReportView = ReportDetailView(frame: .zero, title: "개인정보", description: "개인정보가 포함된 리뷰입니다.").then { _ in
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
    }
    
    private let etcReportTextView = UITextView().then {
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1.0
        $0.isEditable = false
        $0.layer.borderColor = UIColor.appColor(.neutral800).cgColor
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let reportButton = UIButton().then {
        $0.setTitle("신고하기", for: .normal)
        $0.titleLabel?.textColor = UIColor.appColor(.neutral0)
        $0.isEnabled = false
        $0.titleLabel?.textColor = UIColor.appColor(.neutral800)
        $0.backgroundColor = UIColor.appColor(.neutral400)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initialization
    
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
        etcReportTextView.delegate = self
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showToast(message, success):
                self?.showToast(message: message, success: success)
                if success {
                    self?.navigationController?.popViewController(animated: true)
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

extension ShopReviewReportViewController {
    
    private func updateReportButtonState() {
        let anySelectedInReportViews = [nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView].contains { $0.isCheckButtonSelected() }
        let anySelectedInViewController = checkButton.isSelected
        
        let anySelected = anySelectedInReportViews || anySelectedInViewController
        
        reportButton.isEnabled = anySelected
        reportButton.titleLabel?.textColor = anySelected ? UIColor.appColor(.neutral0) : UIColor.appColor(.neutral800)
        reportButton.backgroundColor = anySelected ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral400)
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
    }
    
    @objc private func checkButtonTapped() {
        checkButton.isSelected.toggle()
        
        checkButton.setImage(checkButton.isSelected ? UIImage.appImage(asset: .circleFill) : UIImage.appImage(asset: .circle), for: .normal)
        textCountLabel.textColor = checkButton.isSelected ? UIColor.appColor(.sub500) : UIColor.appColor(.neutral800)
        etcReportTextView.layer.borderColor = checkButton.isSelected ? UIColor.appColor(.sub500).cgColor : UIColor.appColor(.neutral800).cgColor
        etcReportTextView.isEditable = checkButton.isSelected
        
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
        if checkButton.isSelected, let etcText = etcReportTextView.text {
            let report = Report(title: "기타", content: etcText)
            reports.append(report)
        }
    
        let requestModel = ReportReviewRequest(reports: reports)
        inputSubject.send(.reportReview(requestModel))
    }
    
}

extension ShopReviewReportViewController {
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(reportButton)
        [reportReasonLabel, reportGuideLabel, nonSubjectReportView, spamReportView, curseReportView, personalInfoReportView, checkButton, etcLabel, textCountLabel, etcReportTextView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-100)
        }
        reportReasonLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(24)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        reportGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(reportReasonLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        nonSubjectReportView.snp.makeConstraints { make in
            make.top.equalTo(reportGuideLabel.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(76)
        }
        spamReportView.snp.makeConstraints { make in
            make.top.equalTo(nonSubjectReportView.snp.bottom)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(76)
        }
        curseReportView.snp.makeConstraints { make in
            make.top.equalTo(spamReportView.snp.bottom)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(76)
        }
        personalInfoReportView.snp.makeConstraints { make in
            make.top.equalTo(curseReportView.snp.bottom)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(76)
        }
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(personalInfoReportView.snp.bottom).offset(19)
            make.leading.equalTo(view.snp.leading).offset(28)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        etcLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkButton.snp.centerY)
            make.leading.equalTo(checkButton.snp.trailing).offset(16)
        }
        textCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkButton.snp.centerY)
            make.trailing.equalTo(view.snp.trailing).offset(-34)
        }
        etcReportTextView.snp.makeConstraints { make in
            make.top.equalTo(checkButton.snp.bottom).offset(13)
            make.leading.equalTo(view.snp.leading).offset(28)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(156)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        reportButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(48)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}


//
//  CallVanReportEvidenceViewController.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import PhotosUI
import Combine

final class CallVanReportEvidenceViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CallVanReportViewModel
    private let placeHolder = "신고 상황을 확인하기 위해 자세히 작성해주세요."
    private let maximumContextLength = 1000
    private let maxImagesCount = 10
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let contextTitleLabel = UILabel()
    private let contextCountLabel = UILabel()
    private let contextWrapperView = UIView()
    private let contextTextView = UITextView()
    
    private let separatorView = UIView()
    
    private let evidenceTitleLabel = UILabel()
    private let evidenceDescriptionLabel = UILabel()
    private let evidenceCountLabel = UILabel()
    private let evidenceImagesCollectionView = CallVanReportImagesCollectionView()
    private let evidenceImageButton = UIButton()
    
    private let bottomSeparatorView = UIView()
    private let reportButton = UIButton()
    
    // MARK: - Initializer
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
        configureNavigationBar(style: .empty)
        configureView()
        hideKeyboardWhenTappedAround()
        setDelegates()
        setAddTargets()
        addObserver()
    }
}

extension CallVanReportEvidenceViewController {
    
    private func setAddTargets() {
        evidenceImageButton.addTarget(self, action: #selector(evidenceImageButtonTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    @objc private func reportButtonTapped() {
        guard let viewController = navigationController?.viewControllers.first(where: { $0 is CallVanDataViewController }) else {
            assert(false)
            return
        }
        navigationController?.popToViewController(viewController, animated: true)
        showToast(message: "사용자가 신고되었습니다.")
    }
}

extension CallVanReportEvidenceViewController {
    
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
    
    @objc private func keyboardWillShow() {
        var rect = contextWrapperView.convert(contextWrapperView.bounds, to: scrollView)
        rect.size.height += 12
        scrollView.scrollRectToVisible(rect, animated: true)
        
        bottomSeparatorView.snp.updateConstraints {
            $0.bottom.equalTo(reportButton.snp.top).offset(-16)
        }
    }
    
    @objc private func keyboardWillHide() {
        bottomSeparatorView.snp.updateConstraints {
            $0.bottom.equalTo(reportButton.snp.top).offset(-24)
        }
    }
}

extension CallVanReportEvidenceViewController: PHPickerViewControllerDelegate {
    
    @objc private func evidenceImageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.handleSelectedImage(image: selectedImage)
                    }
                }
            }
        }
    }
    
    private func handleSelectedImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
//        inputSubject.send(.uploadFile([imageData]))
    }
}

extension CallVanReportEvidenceViewController: UITextViewDelegate {
    
    private func setDelegates() {
        contextTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.appColor(.gray) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateEvidenceCount()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let count = contextTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        if count == 0 {
            textView.text = placeHolder
            textView.textColor = UIColor.appColor(.gray)
        }
        updateEvidenceCount()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.textColor == UIColor.appColor(.gray) ? "" : (textView.text ?? "")
        
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maximumContextLength
    }
    
    private func updateEvidenceCount() {
        let count: Int
        if contextTextView.textColor == UIColor.appColor(.gray) {
            count = 0
        } else {
            count = contextTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        }
        contextCountLabel.text = "\(count)/\(maximumContextLength)"
    }
}

extension CallVanReportEvidenceViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        
        contextTitleLabel.do {
            $0.text = "신고 상황을 입력해주세요."
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
        }
        contextCountLabel.do {
            $0.text = "0/1000"
            $0.textColor = UIColor.appColor(.neutral500)
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        }
        contextWrapperView.do {
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
        }
        contextTextView.do {
            $0.text = placeHolder
            $0.textColor = UIColor.appColor(.gray)
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        }
        
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
        
        evidenceTitleLabel.do {
            $0.text = "증빙자료 첨부"
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
        }
        evidenceDescriptionLabel.do {
            $0.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 14 * 1.60
            paragraphStyle.maximumLineHeight = 14 * 1.60
            $0.attributedText = NSAttributedString(
                string: "신고 상황에 대한 채팅내역 등 증빙자료로 사용할 이미지를 첨부해주세요.",
                attributes: [
                    .font : UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor : UIColor.appColor(.neutral500),
                    .paragraphStyle : paragraphStyle
                ]
            )
        }
        evidenceCountLabel.do {
            $0.text = "0/10"
            $0.textColor = UIColor.appColor(.neutral500)
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        }
        evidenceImagesCollectionView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 8
        }
        evidenceImageButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage.appImage(asset: .callVanReportImage)
            configuration.attributedTitle = AttributedString(
                "사진 추가하기",
                attributes: AttributeContainer([
                    .font : UIFont.appFont(.pretendardMedium, size: 14),
                    .foregroundColor : UIColor.appColor(.new900)
                ]))
            configuration.imagePadding = 8
            configuration.imagePlacement = .leading
            $0.configuration = configuration
            $0.backgroundColor = UIColor.appColor(.new100)
            $0.layer.cornerRadius = 8
            $0.layer.applySketchShadow(color: UIColor.black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        }
        
        bottomSeparatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        reportButton.do {
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.applySketchShadow(color: UIColor.black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
            $0.layer.cornerRadius = 8
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "신고하기",
                    attributes: [
                        .font : UIFont.appFont(.pretendardSemiBold, size: 15),
                        .foregroundColor : UIColor.appColor(.neutral0)
                    ]
                ), for: .normal
            )
        }
    }
    
    private func setUpLayouts() {
        [contextTextView].forEach {
            contextWrapperView.addSubview($0)
        }
        [contextTitleLabel, contextCountLabel, contextWrapperView, separatorView, evidenceTitleLabel, evidenceDescriptionLabel, evidenceCountLabel, evidenceImagesCollectionView, evidenceImageButton].forEach {
            contentView.addSubview($0)
        }
        [contentView].forEach {
            scrollView.addSubview($0)
        }
        [scrollView, bottomSeparatorView, reportButton].forEach {
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
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        contextTitleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(contentView).offset(12)
            $0.leading.equalTo(contentView).offset(24)
        }
        contextCountLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.bottom.equalTo(contextTitleLabel)
            $0.trailing.equalTo(contentView).offset(-32)
        }
        contextWrapperView.snp.makeConstraints {
            $0.top.equalTo(contextTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(contentView).inset(24)
            $0.height.lessThanOrEqualTo(200)
        }
        contextTextView.snp.makeConstraints {
            $0.top.bottom.equalTo(contextWrapperView).inset(12)
            $0.leading.trailing.equalTo(contextWrapperView).inset(16)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalTo(contentView).inset(24)
            $0.top.equalTo(contextWrapperView.snp.bottom).offset(24)
        }
        
        evidenceTitleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(separatorView.snp.bottom).offset(24)
            $0.leading.equalTo(contentView).offset(24)
        }
        evidenceDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(evidenceTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(contentView).inset(24)
        }
        evidenceCountLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(evidenceDescriptionLabel.snp.bottom)
            $0.trailing.equalTo(contentView).offset(-32)
        }
        evidenceImagesCollectionView.snp.makeConstraints {
            $0.height.equalTo(123)
            $0.top.equalTo(evidenceCountLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(contentView).inset(24)
        }
        evidenceImageButton.snp.makeConstraints {
            $0.height.equalTo(38)
            $0.top.equalTo(evidenceImagesCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(contentView).inset(24)
            $0.bottom.equalTo(contentView)
        }
        
        reportButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reportButton.snp.top).offset(-24)
        }
    }
}

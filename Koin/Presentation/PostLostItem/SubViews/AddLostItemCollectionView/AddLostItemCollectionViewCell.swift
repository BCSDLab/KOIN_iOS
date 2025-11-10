//
//  AddLostArticleCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 1/13/25.
//

import Combine
import UIKit

final class AddLostItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    private var cancellable = Set<AnyCancellable>()
    
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()   // 품목 삭제
    let addImageButtonPublisher = PassthroughSubject<Void, Never>() // 사진 등록
    let imageUrlsPublisher = PassthroughSubject<[String], Never>()  // 사진 등록
    let categoryPublisher = PassthroughSubject<String, Never>()     // 품목 선택
    //let dateButtonPublisher = PassthroughSubject<Void, Never>()
    let datePublisher = PassthroughSubject<String, Never>()         // 날짜 선택
    let textFieldFocusPublisher = PassthroughSubject<CGFloat, Never>()  // 분실 장소
    let locationPublisher = PassthroughSubject<String, Never>()         // 분실 장소
    let textViewFocusPublisher = PassthroughSubject<CGFloat, Never>()   // 내용
    let contentPublisher = PassthroughSubject<String, Never>()          // 내용
    let shouldDismissDropDownPublisher = PassthroughSubject<Void, Never>() // 모든 cell의 dropdown 닫기
    
    private var type: LostItemType = .lost
    private var textViewPlaceHolder = ""
    private var textFieldPlaceHolder = ""
    
    // MARK: - UI Components
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let itemCountLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.primary600)
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let deleteCellButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .trashcanBlue), for: .normal)
    }
    
    private let pictureLabel = UILabel().then {
        $0.text = "사진"
    }
    
    private let pictureMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
    }
    
    private let pictureCountLabel = UILabel().then {
        $0.text = "0/10"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
    }
    
    private let imageUploadCollectionView: LostItemImageCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = LostItemImageCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.appColor(.neutral100)
        return collectionView
    }()
    
    private let addPictureButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .picture)
        var text = AttributedString("사진 등록하기")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.configuration = configuration
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "품목"
    }
    
    private let categoryWarningLabel = UILabel().then {
        $0.isHidden = true
    }
    
    private let categoryMessageLabel = UILabel().then {
        $0.text = "품목을 선택해주세요."
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    private let dateLabel = UILabel().then { _ in
    }
    
    private let dateWarningLabel = UILabel().then {
        $0.isHidden = true
    }
    
    private let chevronImage = UIImageView().then {
        $0.image = UIImage.appImage(asset: .chevronDown)
        $0.isUserInteractionEnabled = false
    }
    private let dateButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.contentHorizontalAlignment = .left
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    private lazy var dropdownView = DatePickerDropdownView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.08, x: 0, y: 4, blur: 10, spread: 0)
        $0.isHidden = true
    }
    
    private let locationLabel = UILabel().then { _ in
    }
    
    private let locationWarningLabel = UILabel().then {
        $0.isHidden = true
    }
    
    private let locationTextField = UITextField().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "내용"
    }
    
    private let contentTextCountLabel = UILabel().then {
        $0.text = "0/1000"
    }
    
    private lazy var contentTextView = UITextView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 0)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.text = textViewPlaceHolder
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        
        // AddTarget
        deleteCellButton.addTarget(self, action: #selector(deleteCellButtonTapped), for: .touchUpInside)
        addPictureButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        locationTextField.addTarget(self, action: #selector(locationTextFieldDidChange), for: .editingChanged)
        
        // SetDelegate
        contentTextView.delegate = self
        locationTextField.delegate = self
        
        // Bind
        imageUploadCollectionView.imageCountPublisher.sink { [weak self] urls in
            self?.addPictureButton.isEnabled = urls.count < 10
            self?.pictureCountLabel.text = "\(urls.count)/10"
            self?.imageUrlsPublisher.send(urls)
            }.store(in: &cancellable)
        imageUploadCollectionView.shouldDismissDropDownPublisher.sink { [weak self] in
            self?.dismissDropdown()
            }.store(in: &cancellable)
        dropdownView.valueChangedPublisher.sink { [weak self] selectedDate in
            let formattedDate = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 M월 d일"
                return formatter.string(from: selectedDate)
            }()
            self?.dateButton.setTitle(formattedDate, for: .normal)
            self?.dateButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
            self?.datePublisher.send(formattedDate)
            self?.dateWarningLabel.isHidden = true
            }.store(in: &cancellable)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Configure
    func configure(index: Int, isSingle: Bool, model: PostLostItemRequest, type: LostItemType) {
        self.type = type
        
        textFieldPlaceHolder = "\(type.description) 장소를 입력해주세요."
        textViewPlaceHolder = "물품이나 \(type.description) 장소에 대한 추가 설명이 있다면 작성해주세요."
        
        dateLabel.text = "\(type.description) 일자"
        pictureMessageLabel.text = "\(type.description)물 사진을 업로드해주세요."
        locationLabel.text = "\(type.description) 장소"
        setUpTexts(type)
        itemCountLabel.text = "\(type.description)물 \(index + 1)"
        
        switch model.location == "" {
        case true:
            locationTextField.text = textFieldPlaceHolder
        case false:
            locationTextField.text = model.location
            locationTextField.textColor = UIColor.appColor(.neutral800)
        }
        
        if model.foundDate.isEmpty {
            dateButton.setTitle("\(type.description) 일자를 입력해주세요.", for: .normal)
            dateButton.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        } else {
            dateButton.setTitle(model.foundDate, for: .normal)
            dateButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        }
        if let content = model.content, content.isEmpty {
            contentTextView.textColor = UIColor.appColor(.neutral500)
            contentTextView.text = textViewPlaceHolder
        } else {
            contentTextView.textColor = UIColor.appColor(.neutral800)
            contentTextView.text = model.content
        }
        deleteCellButton.isHidden = isSingle
        
        let category = model.category
        var isCategorySelected = false
        
        for view in categoryStackView.arrangedSubviews {
            guard let button = view as? UIButton else { continue }
            if button.configuration?.title == category {
                button.configuration?.baseBackgroundColor = UIColor.appColor(.primary600)
                button.configuration?.baseForegroundColor = UIColor.appColor(.neutral0)
                button.layer.borderColor = UIColor.appColor(.primary600).cgColor
                isCategorySelected = true
            } else {
                button.configuration?.baseBackgroundColor = UIColor.appColor(.neutral0)
                button.configuration?.baseForegroundColor = UIColor.appColor(.primary500)
                button.layer.borderColor = UIColor.appColor(.primary500).cgColor
            }
        }
        
        if !isCategorySelected {
            categoryStackView.arrangedSubviews.forEach { view in
                guard let button = view as? UIButton else { return }
                button.configuration?.baseBackgroundColor = UIColor.appColor(.neutral0)
                button.configuration?.baseForegroundColor = UIColor.appColor(.primary500)
                button.layer.borderColor = UIColor.appColor(.primary500).cgColor
            }
        }
    }
}

// MARK: - helper
extension AddLostItemCollectionViewCell {

    private func setUpTexts(_ type: LostItemType) {
        let texts = [
            "품목이 선택되지 않았습니다.",
            "\(type.description)일자가 입력되지 않았습니다.",
            "\(type.description)장소가 입력되지 않았습니다."
        ]
        
        let labels: [UILabel] = [categoryWarningLabel, dateWarningLabel, locationWarningLabel]
        
        labels.enumerated().forEach { index, label in
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage.appImage(asset: .warningOrange)
            imageAttachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
            let spacingAttachment = NSTextAttachment()
            spacingAttachment.bounds = CGRect(x: 0, y: 0, width: 6, height: 1)
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(attachment: imageAttachment))
            attributedString.append(NSAttributedString(attachment: spacingAttachment))
            let text = texts[index]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor: UIColor.appColor(.sub500)
            ]
            attributedString.append(NSAttributedString(string: text, attributes: textAttributes))
            label.attributedText = attributedString
        }
    }
}

// MARK: - @objc
extension AddLostItemCollectionViewCell{
    
    @objc private func addImageButtonTapped() {
        // 열려있는 dropdown 닫기
        shouldDismissDropDownPublisher.send()
        
        addImageButtonPublisher.send()
        
        // TODO: 높이 해결
        //        imageUploadCollectionView.snp.updateConstraints { make in
        //            make.height.equalTo(123)
        //        }
        //        self.setNeedsLayout()
        //           self.layoutIfNeeded()
        //
        //           // Notify collection view to recalculate layout
        //           (self.superview as? UICollectionView)?.performBatchUpdates(nil)
    }
    
    @objc private func deleteCellButtonTapped() {
        // 열려있는 dropdown 닫기
        shouldDismissDropDownPublisher.send()
        
        deleteButtonPublisher.send()
    }
    
    @objc private func stackButtonTapped(_ sender: UIButton) {
        // 열려있는 dropdown 닫기
        shouldDismissDropDownPublisher.send()
    
        categoryWarningLabel.isHidden = true
        categoryPublisher.send(sender.titleLabel?.text ?? "")
        categoryStackView.arrangedSubviews.forEach { view in
               guard let button = view as? UIButton else { return }
               button.isSelected = false
               button.configuration?.baseBackgroundColor = UIColor.appColor(.neutral0)
               button.configuration?.baseForegroundColor = UIColor.appColor(.primary500)
               button.layer.borderColor = UIColor.appColor(.primary500).cgColor
           }

           sender.isSelected = true
           sender.configuration?.baseBackgroundColor = UIColor.appColor(.primary600)
           sender.configuration?.baseForegroundColor = UIColor.appColor(.neutral0)
           sender.layer.borderColor = UIColor.appColor(.primary600).cgColor
    }
}

extension AddLostItemCollectionViewCell {

    func setImage(url: [String]) {
        imageUploadCollectionView.updateImageUrls(url)
    }
    
    func getCellData() -> PostLostItemRequest {
        let category = categoryStackView.arrangedSubviews
            .compactMap { ($0 as? UIButton)?.isSelected == true ? ($0 as? UIButton)?.titleLabel?.text : nil }
            .first ?? "카드"
        
        let location = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        ? locationTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        
        let foundDate = dateButton.titleLabel?.text ?? ""
        let formattedFoundDate = convertToISODate(from: foundDate) ?? ""
        
        
        let content = (contentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && contentTextView.text != textViewPlaceHolder)
        ? contentTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        : ""
        return PostLostItemRequest(
            category: category,
            location: location,
            foundDate: formattedFoundDate,
            content: content,
            images: imageUploadCollectionView.imageUrls,
            registeredAt: "2025-01-10",
            updatedAt: "2025-01-10"
        )
    }
    func convertToISODate(from koreanDate: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
        inputFormatter.dateFormat = "yyyy년 M월 d일" // 입력 형식
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX") // ISO 형식
        outputFormatter.dateFormat = "yyyy-MM-dd" // 원하는 출력 형식
        
        if let date = inputFormatter.date(from: koreanDate) {
            return outputFormatter.string(from: date) // 변환된 ISO 형식 날짜
        } else {
            return nil
        }
    }
    
    func validateInputs() -> Bool {
        var isValid = true
        
        let selectedCategory = categoryStackView.arrangedSubviews.compactMap { $0 as? UIButton }.first { $0.configuration?.baseBackgroundColor == UIColor.appColor(.primary600) }
        if selectedCategory == nil {
            categoryWarningLabel.isHidden = false
            isValid = false
        }
        
        if let title = dateButton.title(for: .normal), title.contains("일자") {
            dateWarningLabel.isHidden = false
            isValid = false
        }
        
        if self.type != .lost {
            if let text = locationTextField.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                locationWarningLabel.isHidden = false
                isValid = false
            }
        }

        return isValid
    }
}

extension AddLostItemCollectionViewCell {
    
    // MARK: - dropdown 닫기/열기
    @objc private func dateButtonTapped(button: UIButton) {
        if dropdownView.isHidden {
            self.endEditing(true)
        }
        dropdownView.isHidden = !dropdownView.isHidden
    }
    // MARK: - dropdown 닫기
    @objc func dismissDropdown() {
        dropdownView.confirmSelection()
        dropdownView.isHidden = true
    }
}

extension AddLostItemCollectionViewCell: UITextViewDelegate {
            
    // MARK: 내용 수정 시작 - 스크롤, placeholder 비우기
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 열려있는 드롭다운  닫기
        shouldDismissDropDownPublisher.send()
        
        // 스크롤
        shouldScrollTo(textView)
        
        // placeholder 비우기
        if textView.text == textViewPlaceHolder && textView.textColor == UIColor.appColor(.neutral500) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    // MARK: 내용 수정 - 글자수 제한, 스크롤
    func textViewDidChange(_ textView: UITextView) {
        // 글자수 제한
        let maxCharacters = 1000
        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }
        contentTextCountLabel.text = "\(textView.text.count)/\(maxCharacters)"
        contentPublisher.send(textView.text)
        
        // 스크롤
        shouldScrollTo(textView)
    }
    
    // MARK: 내용 수정 완료 - placeholder 만들기
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor.appColor(.neutral500)
        }
    }
    
    // MARK: 키보드 닫기
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //textView.resignFirstResponder() // 키보드 숨김
        self.endEditing(true)
        return true
    }
    
    // MARK: 스크롤
    private func shouldScrollTo(_ textView: UITextView) {
        guard let collectionView = self.superview as? UICollectionView,
              let rootView = collectionView.superview else { return }
        
        // 텍스트뷰의 절대적인 Y 좌표 계산
        let absoluteFrame = textView.convert(textView.bounds, to: rootView)
        
        // 텍스트뷰의 Y 좌표값 전송
        textViewFocusPublisher.send(absoluteFrame.origin.y)
    }
}

extension AddLostItemCollectionViewCell: UITextFieldDelegate {
    
    // MARK: 장소 수정 시작 - 스크롤, placeholder 비우기
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 열려있는 dropdown 닫기
        shouldDismissDropDownPublisher.send()
        
        // 스크롤
        shouldScrollTo(textField)
        
        // placeholder 비우기
        if textField.textColor == UIColor.appColor(.neutral500) {
            textField.text = ""
            textField.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    // MARK: 장소 수정 - 스크롤
    @objc private func locationTextFieldDidChange(_ textField: UITextField) {
        // 스크롤
        shouldScrollTo(textField)
        
        if !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            locationWarningLabel.isHidden = true
        }
        locationPublisher.send(textField.text ?? "")
    }
    
    // MARK: 장소 수정 완료 - placeholder 만들기
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            textField.textColor = UIColor.appColor(.neutral500)
            textField.text = "\(type.description) 장소를 입력해주세요."
        }
    }
    
    // MARK: 키보드 닫기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder() // 키보드 숨김
        self.endEditing(true)
        return true
    }
    
    // MARK: 스크롤
    private func shouldScrollTo(_ textField: UITextField) {
        guard let collectionView = self.superview as? UICollectionView,
              let rootView = collectionView.superview else { return }
        
        // 텍스트뷰의 절대적인 Y 좌표 계산
        let absoluteFrame = textField.convert(textField.bounds, to: rootView)
        
        // 텍스트뷰의 Y 좌표값 전송
        textFieldFocusPublisher.send(absoluteFrame.origin.y)
    }
}

extension AddLostItemCollectionViewCell {
    
    private func setUpLayouts() {
        [separateView, itemCountLabel, pictureLabel, pictureMessageLabel, pictureCountLabel, addPictureButton, categoryLabel, categoryMessageLabel, categoryStackView, dateLabel, dateButton, locationLabel, locationTextField, contentLabel, contentTextCountLabel, contentTextView, deleteCellButton, categoryWarningLabel, dateWarningLabel, locationWarningLabel, imageUploadCollectionView, dropdownView].forEach {
            contentView.addSubview($0)
        }
        dateButton.addSubview(chevronImage)
    }
    
    private func setUpConstraints() {
        separateView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(contentView.snp.width)
            make.height.equalTo(6)
        }
        itemCountLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(24)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        deleteCellButton.snp.makeConstraints { make in
            make.leading.equalTo(itemCountLabel.snp.trailing).offset(10)
            make.centerY.equalTo(itemCountLabel.snp.centerY)
            make.width.height.equalTo(20)
        }
        pictureLabel.snp.makeConstraints { make in
            make.top.equalTo(itemCountLabel.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        pictureMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(pictureLabel.snp.bottom)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(19)
        }
        pictureCountLabel.snp.makeConstraints { make in
            make.top.equalTo(pictureLabel.snp.bottom)
            make.trailing.equalTo(addPictureButton.snp.trailing)
            make.height.equalTo(19)
        }
        imageUploadCollectionView.snp.makeConstraints { make in
            make.top.equalTo(pictureMessageLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(addPictureButton)
            make.height.equalTo(123)
        }
        addPictureButton.snp.makeConstraints { make in
            make.top.equalTo(imageUploadCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing).offset(-24)
            make.height.equalTo(38)
        }
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(addPictureButton.snp.bottom).offset(24)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        categoryWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(addPictureButton.snp.bottom).offset(24)
            make.trailing.equalTo(addPictureButton.snp.trailing)
            make.height.equalTo(22)
        }
        categoryMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(19)
        }
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(categoryMessageLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(29.5)
            make.trailing.equalTo(contentView.snp.trailing).offset(-29.5)
            make.height.equalTo(38)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        dateWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.top)
            make.trailing.equalTo(addPictureButton.snp.trailing)
            make.height.equalTo(22)
        }
        dateButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(40)
            make.trailing.equalTo(contentView.snp.trailing).offset(-24)
        }
        chevronImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        dropdownView.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(dateButton)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(dateButton.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        locationWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.top)
            make.trailing.equalTo(addPictureButton.snp.trailing)
            make.height.equalTo(22)
        }
        locationTextField.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(8)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.trailing.equalTo(dateButton.snp.trailing)
            make.height.equalTo(35)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(locationTextField.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        contentTextCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.top)
            make.trailing.equalTo(dateButton.snp.trailing)
            make.height.equalTo(19)
        }
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.trailing.equalTo(dateButton.snp.trailing)
            make.height.greaterThanOrEqualTo(59)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
    }
    
    private func setUpAttributes() {
        [pictureMessageLabel, pictureCountLabel, categoryMessageLabel, contentTextCountLabel].forEach {
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        [pictureLabel, categoryLabel, dateLabel, locationLabel, contentLabel].forEach {
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        }
    }
    
    private func setUpStackView() {
        let items = ["카드", "신분증", "지갑", "전자제품", "기타"]
        let widths = [49, 61, 49, 73, 49]
        
        let buttons: [UIButton] = zip(items, widths).enumerated().map { index, element in
            let (title, width) = element
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.baseForegroundColor = UIColor.appColor(.primary500)
            configuration.baseBackgroundColor = UIColor.appColor(.neutral0)
            configuration.cornerStyle = .medium
            button.configuration = configuration
            
            let attributedTitle = AttributedString(title, attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardMedium, size: 14)
            ]))
            button.configuration?.attributedTitle = attributedTitle
            
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appColor(.primary500).cgColor
            button.layer.cornerRadius = 19
            button.clipsToBounds = true
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.textAlignment = .center
            button.tag = index
            button.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            button.addTarget(self, action: #selector(stackButtonTapped(_:)), for: .touchUpInside)
            
            return button
        }
        categoryStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        buttons.forEach { button in
            categoryStackView.addArrangedSubview(button)
        }
        
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .fill
        categoryStackView.distribution = .equalSpacing
        categoryStackView.spacing = 8
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpAttributes()
        setUpStackView()
    }
}

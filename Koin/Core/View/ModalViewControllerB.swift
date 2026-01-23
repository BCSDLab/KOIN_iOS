//
//  ModalViewControllerB.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import Combine
import UIKit

class ModalViewControllerB: UIViewController {
    
    // MARK: - Properties
    private let onLeftButtonTapped: (()->Void)?
    private let onRightButtonTapped: ()->Void
    
    var containerWidth: CGFloat = 0
    var containerHeight: CGFloat = 0
    var paddingBetweenLabels: CGFloat = 0
    var titleText: String = ""
    var subTitleText: String?
    var titleColor: UIColor = .black
    var subTitleColor: UIColor? = .black
    
    // MARK: - UI Components
    private let messageLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    private let subMessageLabel = UILabel().then {
        $0.numberOfLines = 0
    }

    private let closeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let rightButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private var contentViewInContainer: UIView?
    
    init(onLeftButtonTapped: (()->Void)? = nil, onRightButtonTapped: @escaping ()->Void, width: CGFloat, height: CGFloat, paddingBetweenLabels: CGFloat, title: String, subTitle: String?, titleColor: UIColor, subTitleColor: UIColor?, rightButtonText: String = "로그인하기") {
        self.onLeftButtonTapped = onLeftButtonTapped
        self.onRightButtonTapped = onRightButtonTapped
        super.init(nibName: nil, bundle: nil)
        self.containerWidth = width
        self.containerHeight = height
        self.paddingBetweenLabels = paddingBetweenLabels
        self.titleText = title
        self.subTitleText = subTitle
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.rightButton.setTitle(rightButtonText, for: .normal)
    }
    
    convenience init(onLeftButtonTapped: (()->Void)? = nil, onRightButtonTapped: @escaping ()->Void, width: CGFloat, height: CGFloat, title: String, titleColor: UIColor, rightButtonText: String = "로그인하기") {
        
        self.init(onLeftButtonTapped: onLeftButtonTapped, onRightButtonTapped: onRightButtonTapped, width: width, height: height, paddingBetweenLabels: 0, title: title, subTitle: nil, titleColor: titleColor, subTitleColor: nil, rightButtonText: rightButtonText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideOfContainerView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func closeButtonTapped() {
        onLeftButtonTapped?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func rightButtonTapped() {
        onRightButtonTapped()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapOutsideOfContainerView(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updateRightButton(buttonColor: UIColor = .appColor(.primary500), borderWidth: CGFloat, title: String) {
        rightButton.backgroundColor = buttonColor
        rightButton.layer.borderWidth = borderWidth
        rightButton.setTitle(title, for: .normal)
    }
    
    func updateCloseButton(buttonColor: UIColor = .systemBackground, borderWidth: CGFloat, title: String) {
        closeButton.backgroundColor = buttonColor
        closeButton.layer.borderWidth = borderWidth
        closeButton.setTitle(title, for: .normal)
    }
    
    func updateMessageLabel(font: UIFont = .appFont(.pretendardMedium, size: 18), alignment: NSTextAlignment = .center, title: String? = nil) {
        if let title = title { titleText = title }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = alignment
        let attributedString = NSMutableAttributedString(string: titleText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: titleText.count))
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: titleText.count))
        attributedString.addAttribute(.foregroundColor, value: titleColor, range: NSRange(location: 0, length: titleText.count))
        
        messageLabel.attributedText = attributedString
    }
    
    func updateSubMessageLabel(font: UIFont = .appFont(.pretendardRegular, size: 14), alignment: NSTextAlignment = .center, title: String? = nil) {
        if let title = title { subTitleText = title }
        
        if let subTitleText {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.alignment = alignment
            let attributedString = NSMutableAttributedString(string: subTitleText)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: subTitleText.count))
            attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: subTitleText.count))
            attributedString.addAttribute(.foregroundColor, value: subTitleColor, range: NSRange(location: 0, length: subTitleText.count))
            
            subMessageLabel.attributedText = attributedString
        }
        else {
            updateMessageLabel(font: .appFont(.pretendardMedium, size: 16))
        }
    }
    
    func setContentViewInContainer(view: UIView, frame: CGRect) {
        self.contentViewInContainer = view
        self.contentViewInContainer?.frame = frame
        
        guard let contentViewInContainer = contentViewInContainer else { return }
        containerView.addSubview(contentViewInContainer)
        contentViewInContainer.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(contentViewInContainer.frame.height)
        }
        closeButton.snp.remakeConstraints { make in
            make.top.equalTo(contentViewInContainer.snp.bottom).offset(24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
        rightButton.snp.remakeConstraints { make in
            make.top.equalTo(contentViewInContainer.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.centerX).offset(2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
    }
}

extension ModalViewControllerB {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, subMessageLabel, closeButton, rightButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(containerWidth)
            make.height.equalTo(containerHeight)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(paddingBetweenLabels)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
        rightButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.centerX).offset(2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
        updateMessageLabel()
        updateSubMessageLabel()
    }
}

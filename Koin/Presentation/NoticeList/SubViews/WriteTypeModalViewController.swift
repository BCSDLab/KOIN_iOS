//
//  WriteTypeModalViewController.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import UIKit

final class WriteTypeModalViewController: UIViewController {
    
    // MARK: - properties
    let findButtonPublisher = PassthroughSubject<Void, Never>()
    let lostButtonPublisher = PassthroughSubject<Void, Never>()
    
    
    // MARK: - UI Components
    private let findButton = UIButton()
    private let lostButton = UIButton()
    private let writeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        findButton.addTarget(self, action: #selector(findButtonTapped), for: .touchUpInside)
        lostButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        writeButton.addTarget(self, action: #selector(writeButtonTapped), for: .touchUpInside)
    }
    
    @objc func findButtonTapped() {
        findButtonPublisher.send()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        lostButtonPublisher.send()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func writeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension WriteTypeModalViewController {
    
    private func setUpLayOuts() {
       
        [findButton, lostButton, writeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        findButton.snp.makeConstraints { make in
            make.bottom.equalTo(lostButton.snp.top).offset(-16)
            make.trailing.equalTo(view.snp.trailing).offset(-21)
            make.width.equalTo(156)
            make.height.equalTo(42)
        }
        lostButton.snp.makeConstraints { make in
            make.bottom.equalTo(writeButton.snp.top).offset(-16)
            make.trailing.equalTo(view.snp.trailing).offset(-21)
            make.width.equalTo(156)
            make.height.equalTo(42)
        }
        writeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-63)
            make.trailing.equalTo(view.snp.trailing).offset(-21)
            make.width.equalTo(94)
            make.height.equalTo(42)
        }
    }
    
    private func setUpButtons() {
        let buttonConfigs: [(button: UIButton, image: UIImage?, text: String)] = [
            (findButton, UIImage.appImage(asset: .findPerson), "주인을 찾아요"),
            (lostButton, UIImage.appImage(asset: .lostItem), "잃어버렸어요"),
            (writeButton, UIImage.appImage(asset: .pencil), "글쓰기")
        ]
        buttonConfigs.forEach { button, image, text in
            var configuration = UIButton.Configuration.plain()
            configuration.image = image
            var attributedText = AttributedString(text)
            attributedText.font = UIFont.appFont(.pretendardMedium, size: 16)
            configuration.attributedTitle = attributedText
            configuration.imagePadding = 0
            configuration.imagePlacement = .leading
            configuration.baseForegroundColor = UIColor.appColor(.neutral600)
            
            button.backgroundColor = UIColor.appColor(.neutral50)
            button.configuration = configuration
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 18
            button.contentHorizontalAlignment = .center
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        }
    }

    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpButtons()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}

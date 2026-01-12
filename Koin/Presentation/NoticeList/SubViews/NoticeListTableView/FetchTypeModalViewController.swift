//
//  FetchTypeModalViewController.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Foundation

import Combine
import UIKit

final class FetchTypeModalViewController: UIViewController {
    
    // MARK: - properties
    
    private var inset: CGFloat = 0
    let typePublisher = PassthroughSubject<LostItemType?, Never>()
    
    // MARK: - UI Components
    private let originalButton = UIButton().then { _ in
    }
    private let allItemButton = UIButton().then { _ in
    }
    private let lostItemButton = UIButton().then { _ in
    }
    private let foundItemButton = UIButton().then { _ in
    }
    private let buttonWrappedView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        [allItemButton, lostItemButton, foundItemButton].forEach {
            $0.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        }
        originalButton.addTarget(self, action: #selector(originalButtonTapped), for: .touchUpInside)
    }
    
    func setInset(inset: CGFloat) {
        self.inset = inset
        configureView()
    }
    
    func setText(type: LostItemType?) {
        let buttonText: String
        switch type {
        case .lost, .found: buttonText = "\(type?.description ?? "")물"
        case nil: buttonText = "물품 전체"
        }
        
        var configuration = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "chevron.up", withConfiguration: symbolConfig)
        configuration.image = image
        var text = AttributedString(buttonText)
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        configuration.imagePlacement = .trailing
        originalButton.backgroundColor = UIColor.appColor(.info200)
        originalButton.configuration = configuration
        originalButton.layer.cornerRadius = 12
        originalButton.layer.masksToBounds = true
        
    }
    @objc private func typeButtonTapped(_ button: UIButton) {
        switch button {
        case allItemButton: typePublisher.send(nil)
        case lostItemButton: typePublisher.send(.lost)
        case foundItemButton: typePublisher.send(.found)
        default: break
        }
        dismiss(animated: true)
    }
    
    @objc private func originalButtonTapped() {
        dismiss(animated: true)
    }

}

extension FetchTypeModalViewController {
    
    private func setUpLayOuts() {
        [originalButton, buttonWrappedView].forEach {
            view.addSubview($0)
        }
        [allItemButton, lostItemButton, foundItemButton].forEach {
            buttonWrappedView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        originalButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(inset + 16)
            make.trailing.equalToSuperview().offset(-24)
            make.width.equalTo(96)
            make.height.equalTo(32)
        }
        buttonWrappedView.snp.makeConstraints { make in
            make.top.equalTo(originalButton.snp.bottom).offset(9)
            make.trailing.equalTo(originalButton)
            make.width.equalTo(96)
            make.height.equalTo(114)
        }
        allItemButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        lostItemButton.snp.makeConstraints { make in
            make.top.equalTo(allItemButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        foundItemButton.snp.makeConstraints { make in
            make.top.equalTo(lostItemButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
    }
    
    private func setUpButtons() {
        var configuration = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "chevron.up", withConfiguration: symbolConfig)
        configuration.image = image
        var text = AttributedString("물품 전체")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        configuration.imagePlacement = .trailing
        originalButton.backgroundColor = UIColor.appColor(.info200)
        originalButton.configuration = configuration
        originalButton.layer.cornerRadius = 12
        originalButton.layer.masksToBounds = true
        
        let buttonConfigs: [(button: UIButton, text: String)] = [
            (allItemButton, "물품 전체"),
            (lostItemButton, "분실물"),
            (foundItemButton, "습득물")
        ]
        buttonConfigs.forEach { button, text in
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
            button.backgroundColor = UIColor.appColor(.info200)
            button.setTitleColor(UIColor.appColor(.primary600), for: .normal)
        }
    }

    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpButtons()
        view.backgroundColor = .clear
    }
}

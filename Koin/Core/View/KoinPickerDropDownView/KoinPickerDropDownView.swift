//
//  KoinPickerDropDownView.swift
//  koin
//
//  Created by 홍기정 on 3/6/26.
//

import UIKit
import Combine

protocol KoinPickerDropDownViewDelegate: AnyObject {
    func reset(koinPicker: KoinPickerDropDownView)
    func reset(koinPicker: KoinPickerDropDownView, initialDate: Date)
    func selectedItemUpdated(koinPicker: KoinPickerDropDownView, selectedItem: [String])
}

final class KoinPickerDropDownView: UIView {
    
    // MARK: - Publisher
    let selectedItemPublisher = PassthroughSubject<[String], Never>()
    let applyButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Properties
    private var selectedItem: [String] = [] {
        didSet {
            selectedItemPublisher.send(selectedItem)
        }
    }
    private let delegate: KoinPickerDropDownViewDelegate
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let pickerView = KoinPickerViewB(columnSpacing: 40)
    private let separatorView = UIView()
    private let resetButton = UIButton()
    private let applyButton = UIButton()
    
    // MARK: - Initializer
    init(delegate: KoinPickerDropDownViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        configureView()
        bind()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Called by ViewController
    func reset(initialDate: Date) {
        delegate.reset(koinPicker: self, initialDate: initialDate)
    }
    
    // MARK: - Called By Delegate
    func reset(items: [[String]], selectedItem: [String], columnWidths: [CGFloat]) {
        self.selectedItem = selectedItem
        pickerView.reset(items: items, selectedItem: selectedItem, columnWidths: columnWidths)
    }
    
    func update(selectedItem: [String]) {
        self.selectedItem = selectedItem
        pickerView.update(selectedItem: selectedItem)
    }
}

extension KoinPickerDropDownView {
    
    private func bind() {
        pickerView.selectedItemPublisher.sink { [weak self] selectedItem in
            guard let self else { return }
            delegate.selectedItemUpdated(koinPicker: self, selectedItem: selectedItem)
        }.store(in: &subscriptions)
    }
    
    private func setAddTargets() {
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc private func applyButtonTapped() {
        applyButtonTappedPublisher.send()
    }
    
    @objc private func resetButtonTapped() {
        delegate.reset(koinPicker: self)
    }
}

extension KoinPickerDropDownView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = UIColor.appColor(.neutral100)
        
        pickerView.do {
            $0.backgroundColor = .clear
        }
        
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
        
        applyButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "확인",
                attributes: [
                    .font : UIFont.appFont(.pretendardMedium, size: 14),
                    .foregroundColor : UIColor.appColor(.new500)
                ]
            ), for: .normal)
        }
        
        resetButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "초기화",
                attributes: [
                    .font : UIFont.appFont(.pretendardMedium, size: 14),
                    .foregroundColor : UIColor.appColor(.new500)
                ]
            ), for: .normal)
        }
    }
    
    private func setUpLayouts() {
        [pickerView, separatorView, resetButton, applyButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        pickerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(pickerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        applyButton.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(separatorView.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-12)
        }
        resetButton.snp.makeConstraints {
            $0.top.bottom.equalTo(applyButton)
            $0.trailing.equalTo(applyButton.snp.leading).offset(-16)
        }
    }
}

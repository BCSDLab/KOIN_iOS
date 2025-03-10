//
//  AddClassHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import Combine
import UIKit

final class AddClassHeaderView: UICollectionReusableView {
    
    static let identifier = "AddClassHeaderView"
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    let filterButtonPublisher = PassthroughSubject<Void, Never>()
    let addDirectButtonPublisher = PassthroughSubject<Void, Never>()
    let searchClassPublisher = PassthroughSubject<String, Never>()
    
    private let addDirectButton = UIButton().then {
        $0.setTitle("직접추가", for: .normal)
        $0.setTitleColor(UIColor.appColor(.primary500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let classLabel = UILabel().then {
        $0.text = "수업추가"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.primary600)
    }
    
    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let separateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let filterButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .classFilter), for: .normal)
    }
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "수업을 입력해주세요"
        textField.font = UIFont.appFont(.pretendardRegular, size: 14)
        textField.tintColor = UIColor.appColor(.neutral300)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        let searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage.appImage(asset: .search), for: .normal)
        searchButton.tintColor = UIColor.appColor(.neutral600)
        searchButton.addTarget(nil, action: #selector(AddClassHeaderView.searchButtonTapped), for: .touchUpInside)
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 35))
        searchButton.frame = CGRect(x: 5, y: 5, width: 24, height: 24)
        iconContainerView.addSubview(searchButton)
        textField.rightView = iconContainerView
        textField.rightViewMode = .always
        return textField
    }()

    
    private let separateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        addDirectButton.addTarget(self, action: #selector(addDirectButtonTapped), for: .touchUpInside)
        searchTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddClassHeaderView: UITextFieldDelegate {
    
    @objc private func searchButtonTapped() {
        guard let text = searchTextField.text, !text.isEmpty else { return }
        searchClassPublisher.send(text)
        searchTextField.resignFirstResponder() // 키보드 닫기
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let text = textField.text else { return false }
            searchClassPublisher.send(text)
            textField.resignFirstResponder() // 키보드 닫기
            return true
        }
    
    @objc private func completeButtonTapped() {
        completeButtonPublisher.send(())
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        searchClassPublisher.send(text)
    }
    @objc private func filterButtonTapped() {
        filterButtonPublisher.send()
    }
    @objc private func addDirectButtonTapped() {
        addDirectButtonPublisher.send()
    }
}
extension AddClassHeaderView {
    private func setupViews() {
        self.backgroundColor = .systemBackground
        [addDirectButton, classLabel, completeButton, separateView1, filterButton, searchTextField, separateView2].forEach {
            self.addSubview($0)
        }
        addDirectButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.width.equalTo(63)
            make.height.equalTo(29)
        }
        classLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(29)
        }
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.width.equalTo(35)
            make.height.equalTo(29)
        }
        separateView1.snp.makeConstraints { make in
            make.top.equalTo(classLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(separateView1.snp.bottom).offset(11)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.height.width.equalTo(29)
        }
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(separateView1.snp.bottom).offset(8)
            make.leading.equalTo(filterButton.snp.trailing).offset(31)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(35)
        }
        separateView2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
    }
}

//
//  AddClassHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import UIKit

final class AddClassHeaderView: UICollectionReusableView {
    
    static let identifier = "AddClassHeaderView"
    
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
        let imageView = UIImageView(image: UIImage.appImage(asset: .search))
        imageView.contentMode = .scaleAspectFit
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + 12, height: 24))
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        iconContainerView.addSubview(imageView)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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

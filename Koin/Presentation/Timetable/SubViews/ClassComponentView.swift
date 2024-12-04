//
//  ClassComponentView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import UIKit

final class ClassComponentView: UIView, UITextFieldDelegate {
    
    var textValue: String {
        return textField.text ?? ""
    }
    
    private let mainLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 12)
    }
    
    private let pointLabel = PointLabel(text: "").then { _ in
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let textField = UITextField().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.tintColor = UIColor.appColor(.neutral500)
    }
    
    // MARK: - Initializers
    init(text: String, isPoint: Bool) {
        super.init(frame: .zero)
        mainLabel.text = text
        setupViews()
        
        mainLabel.text = text
        pointLabel.setText(text: text)
        textField.placeholder = "\(text)\(text.hasFinalConsonant() ? "을":"를") 입력하세요."
        pointLabel.isHidden = !isPoint
        mainLabel.isHidden = isPoint
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        [mainLabel, pointLabel, separateView, textField].forEach {
            self.addSubview($0)
        }
        
        mainLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.snp.leading).offset(13)
            make.height.equalTo(16)
            make.width.equalTo(32)
        }
        pointLabel.snp.makeConstraints { make in
            make.edges.equalTo(mainLabel)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(5)
            make.leading.equalTo(pointLabel.snp.trailing).offset(7)
            make.width.equalTo(2)
            make.bottom.equalTo(self.snp.bottom).offset(-5)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(7)
            make.leading.equalTo(separateView).offset(16)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-7)
        }
    }
    
}

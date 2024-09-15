//
//  ReportDetailView.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine
import Then
import UIKit

final class ReportDetailView: UIView {
    
    // MARK: - Properties
    let checkButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .circle), for: .normal)
    }
    
    private let reportTitleLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let reportDescriptionLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, title: String, description: String) {
        self.init(frame: frame)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        reportTitleLabel.text = title
        reportDescriptionLabel.text = description
    }
}

extension ReportDetailView {
    @objc private func checkButtonTapped() {
        checkButton.isSelected.toggle()
        checkButton.setImage(checkButton.isSelected ? UIImage.appImage(asset: .filledCircle) : UIImage.appImage(asset: .circle), for: .normal)
        checkButtonPublisher.send(())
    }
    
    func isCheckButtonSelected() -> Bool {
        return checkButton.isSelected
    }
    
    func getReportInfo() -> (title: String, content: String) {
        return (title: reportTitleLabel.text ?? "", content: reportDescriptionLabel.text ?? "")
    }
    
}
extension ReportDetailView {
    private func setUpLayOuts() {
        [checkButton, reportTitleLabel, reportDescriptionLabel, separateView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        reportTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(14)
            make.leading.equalTo(checkButton.snp.trailing).offset(16)
        }
        reportDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(reportTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(checkButton.snp.trailing).offset(16)
        }
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(26)
            make.leading.equalTo(self.snp.leading).offset(8)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(reportDescriptionLabel.snp.bottom).offset(14)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}

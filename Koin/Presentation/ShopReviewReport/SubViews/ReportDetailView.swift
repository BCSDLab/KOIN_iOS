//
//  ReportDetailView.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine
import UIKit
import SnapKit

final class ReportDetailView: UIView {
    
    // MARK: - Properties
    
    let checkButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .circle)?.resize(to: CGSize(width: 16, height: 16)), for: .normal)
        $0.isUserInteractionEnabled = false
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
        $0.backgroundColor = UIColor.appColor(.neutral300)
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
        reportTitleLabel.text = title
        reportDescriptionLabel.text = description
        setupGesture()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapGesture)
    }
}

extension ReportDetailView {
    
    @objc private func viewTapped() {
        checkButton.isSelected.toggle()
        let image = checkButton.isSelected
            ? UIImage.appImage(asset: .filledCircle)?.resize(to: CGSize(width: 16, height: 16))?.withTintColor(UIColor.appColor(.new500), renderingMode: .alwaysOriginal)
            : UIImage.appImage(asset: .circle)?.resize(to: CGSize(width: 16, height: 16))
        checkButton.setImage(image, for: .normal)
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
        [separateView, checkButton, reportTitleLabel, reportDescriptionLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        checkButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(16)
        }
        
        reportTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(checkButton.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        reportDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(reportTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(checkButton.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        separateView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
    }
}

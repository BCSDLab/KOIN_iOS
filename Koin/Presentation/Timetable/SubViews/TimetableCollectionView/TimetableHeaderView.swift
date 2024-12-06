//
//  TimetableHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/18/24.
//

import UIKit

final class TimetableHeaderView: UICollectionReusableView {
    
    static let identifier = "TimetableHeaderView"
    
    private let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        return view
    }()
    
    private let days: [String] = ["월", "화", "수", "목", "금"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDaysHeader()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDaysHeader() {
        // 각 요일 Label 추가
        days.forEach { day in
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.textColor = UIColor.appColor(.neutral500)
            label.font = UIFont.appFont(.pretendardBold, size: 13)
            label.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            label.layer.borderWidth = 0.5
            daysStackView.addArrangedSubview(label)
        }
        addSubview(daysStackView)
        addSubview(separateView)
    }
    
    private func setupViews() {
        self.backgroundColor = .systemBackground
        
        daysStackView.snp.makeConstraints { make in
            make.top.trailing.height.equalToSuperview()
            make.leading.equalToSuperview().offset(17)
        }
        separateView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.trailing.equalTo(daysStackView.snp.leading)
        }
        
    
    }
}

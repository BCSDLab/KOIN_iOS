//
//  DiningOperatingTimeHeaderView.swift
//  koin
//
//  Created by 김나훈 on 6/8/24.
//

import UIKit

final class DiningOperatingTimeHeaderView: UICollectionReusableView {
    static let identifier = "DiningOperatingTimeHeaderView"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "시작시간"
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "마감시간"
        return label
    }()
    
    private let separateView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral400)
        return view
    }()
    
    private let separateView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral400)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setUpLabels()
        self.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        [timeLabel, startTimeLabel, endTimeLabel, separateView1, separateView2].forEach { component in
            addSubview(component)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(self.snp.centerX).offset(-115)
        }
        startTimeLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        endTimeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(self.snp.centerX).offset(115)
        }
        separateView1.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        separateView2.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setUpLabels() {
        [timeLabel, startTimeLabel, endTimeLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardMedium, size: 14)
            label.textColor = UIColor.appColor(.neutral800)
        }
    }
}

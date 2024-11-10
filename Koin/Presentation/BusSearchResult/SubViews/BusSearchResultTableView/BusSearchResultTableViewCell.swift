//
//  BusSearchResultTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import SnapKit
import Then
import UIKit

final class BusSearchResultTableViewCell: UITableViewCell {
    //MARK: - UI Components
    private let busTypeLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 11)
        $0.textColor = .appColor(.neutral600)
        $0.textAlignment = .center
        $0.backgroundColor = .appColor(.orange100)
    }
    
    private let busTimeLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 20)
        $0.textColor = .appColor(.neutral800)
        $0.textAlignment = .left
    }
    
    private let remainTimeLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.info700)
        $0.textAlignment = .right
    }
    
    //MARK: -Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    //추후 API 명세를 받고 모델을 정의할 것
    func configure(searchModel: TempBusSearchResult) {
        busTypeLabel.text = String(searchModel.busType.koreanDescription.prefix(2))
        busTimeLabel.text = searchModel.busTime
        remainTimeLabel.text = searchModel.remainTime
    }
   
}

extension BusSearchResultTableViewCell {
    private func setUpLayouts() {
        [busTypeLabel, busTimeLabel, remainTimeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busTypeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(33)
            $0.top.equalToSuperview().offset(8)
            $0.width.equalTo(28)
            $0.height.equalTo(18)
        }
        busTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(busTypeLabel)
            $0.top.equalTo(busTypeLabel.snp.bottom)
            $0.height.equalTo(32)
        }
        remainTimeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(31)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

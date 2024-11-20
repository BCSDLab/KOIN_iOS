//
//  TimetableCell.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

final class TimetableCell: UITableViewCell {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    private let bookmarkImageView = UIImageView().then { _ in
    }
    private let settingButton = UIButton().then {
        $0.setTitle("설정", for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Cell
    func configure(with timetable: FrameDTO) {
        titleLabel.text = timetable.timetableName
        bookmarkImageView.image = timetable.isMain ? UIImage.appImage(asset: .bookmark) : UIImage()
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(bookmarkImageView)
        contentView.addSubview(settingButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
        }
        bookmarkImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(14)
            make.height.equalTo(20)
        }
        settingButton.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(26)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-32)
        }
    }
}

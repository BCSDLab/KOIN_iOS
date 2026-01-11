//
//  ImageDropDownCell.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import DropDown
import Then
import UIKit

final class ImageDropDownCell: DropDownCell {

    
    private let dropDownLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let dropDownImageView = UIImageView().then { _ in
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, image: UIImage?) {
        dropDownLabel.text = text
        dropDownImageView.image = image
    }

    private func setupView() {
        [dropDownLabel, dropDownImageView].forEach {
            contentView.addSubview($0)
        }
        dropDownLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(10)
        }
        dropDownImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(dropDownLabel.snp.trailing).offset(5)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
    }
}

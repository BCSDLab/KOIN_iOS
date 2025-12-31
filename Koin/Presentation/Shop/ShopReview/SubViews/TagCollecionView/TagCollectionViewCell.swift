//
//  TagCollectionViewCell.swift
//  koin
//
//  Created by 김성민 on 11/3/25.
//

import UIKit
import SnapKit

class TagCollectionViewCell: UICollectionViewCell {
    let identifier = "TagCell"
    var onTapCancel: (() -> Void)?
    
    
    private let tagLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.new300)
    }
    
    private let cancelButton = UIButton(configuration: .plain()).then{
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .cancelNew300)
        config.contentInsets = .init(top: 4.08, leading: 4.08, bottom: 4.08, trailing: 4.08)
        $0.configuration = config
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(){
        setUpLayouts()
        setUpConstraints( )
    }
    
    
    private func setUpLayouts() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 5
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.appColor(.new300).cgColor
        [tagLabel, cancelButton].forEach {
            self.addSubview( $0 )
        }
    }
    
    private func setUpConstraints() {
        tagLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.leading.equalTo(tagLabel.snp.trailing).offset(4)
            $0.size.equalTo(14)
            $0.top.bottom.equalToSuperview().inset(5.5)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
    }

    //MARK: - Configure
    func configure(title: String){
        tagLabel.text = title
    }

    //MARK: - @Objc
    @objc private func cancelButtonTapped() {
        onTapCancel?()
    }
    
    //MARK: - setAddTarget
    private func setAddTarget(){
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    
}




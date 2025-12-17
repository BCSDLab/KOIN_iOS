//
//  AddDirectCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectCollectionViewCell: UICollectionViewCell {
    
    var cancellables = Set<AnyCancellable>()
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()

    let selectTimeView = SelectTimeView(frame: .zero, size: .small).then { _ in
    }
    
    private let placeView = ClassComponentView(text: "장소", isPoint: false).then {
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .delete), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func configure(text: String) {
        
    }
}

extension AddDirectCollectionViewCell {
    @objc private func deleteButtonTapped() {
        deleteButtonPublisher.send()
    }
}

extension AddDirectCollectionViewCell {
    private func setUpLayouts() {
        [selectTimeView, placeView, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.height.equalTo(24)
        }
        selectTimeView.snp.makeConstraints { make in
            make.top.equalTo(deleteButton.snp.bottom).offset(6)
            make.leading.equalTo(self.snp.leading).offset(13.5)
            make.trailing.equalTo(self.snp.trailing).offset(-13.5)
            make.height.equalTo(35)
        }
        placeView.snp.makeConstraints { make in
            make.top.equalTo(selectTimeView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(selectTimeView)
            make.height.equalTo(38)
        }
    }
    
    private func setUpBorder() {
        self.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpBorder()
    }
}

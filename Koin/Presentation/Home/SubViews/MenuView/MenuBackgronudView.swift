//
//  MenuBackgronudView.swift
//  koin
//
//  Created by 김나훈 on 4/8/24.
//

import UIKit

final class MenuBackgroundView: UIView {
    
    // MARK: - UI Components
    
    private let menuView: MenuView = {
        let menuView = MenuView(frame: .zero)
        menuView.clipsToBounds = true
        menuView.layer.cornerRadius = 8
        menuView.layer.borderWidth = 1.0
        menuView.backgroundColor = .systemBackground
        menuView.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        return menuView
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension MenuBackgroundView {
    func updateDining(_ item: DiningItem?, _ type: DiningType) {
        menuView.updateDining(item, type)
    }
}
// MARK: UI Settings

extension MenuBackgroundView {
    private func setUpLayOuts() {
        [menuView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        menuView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(16)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.height.equalTo(200)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.backgroundColor = UIColor.appColor(.neutral50)
    }
    
}



//
//  LostItemPostOptionController.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit

final class LostItemPostOptionController: UIViewController {
    
    // MARK: - Properties
    private let onFoundButtonTapped: ()->Void
    private let onLostButtonTapped: ()->Void
    
    // MARK: - UI Components
    private let filterTitleLabel = UILabel().then {
        $0.text = "유형을 선택해주세요"
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.tintColor = .appColor(.primary500)
    }
    private let closeButton = UIButton().then {
        $0.setImage(.appImage(asset: .cancelNeutral500), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    private let topSeparatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    private let foundButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .findPerson)
        configuration.attributedTitle = AttributedString("주인을 찾아요", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardBold, size: 18),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.imagePadding = 8
        $0.configuration = configuration
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    private let lostButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .lostItem)
        configuration.attributedTitle = AttributedString("잃어버렸어요", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardBold, size: 18),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.imagePadding = 8
        $0.configuration = configuration
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    private let bottomSeparatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    // MARK: - Initializer
    init(onFoundButtonTapped: @escaping () -> Void,
         onLostButtonTapped: @escaping () -> Void) {
        self.onFoundButtonTapped = onFoundButtonTapped
        self.onLostButtonTapped = onLostButtonTapped
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTargets()
    }
}

extension LostItemPostOptionController {
    
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        foundButton.addTarget(self, action: #selector(foundButtonTapped), for: .touchUpInside)
        lostButton.addTarget(self, action: #selector(lostButtonTapped), for: .touchUpInside)
    }
    @objc private func closeButtonTapped() {
        dismissView()
    }
    @objc private func foundButtonTapped() {
        onFoundButtonTapped()
    }
    @objc private func lostButtonTapped() {
        onLostButtonTapped()
    }
}

extension LostItemPostOptionController {
    
    private func setUpLayouts() {
        [filterTitleLabel, closeButton, topSeparatorView, foundButton, lostButton, bottomSeparatorView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstaints() {
        filterTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(29)
        }
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalTo(filterTitleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        topSeparatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(filterTitleLabel.snp.bottom).offset(12)
        }
        foundButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(49)
            $0.top.equalTo(topSeparatorView.snp.bottom).offset(16)
        }
        lostButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(49)
            $0.top.equalTo(foundButton.snp.bottom).offset(12)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(lostButton.snp.bottom).offset(12)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstaints()
    }
}

//
//  CallVanBottomSheetViewController.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit
import Then
import SnapKit

extension CallVanBottomSheetViewController {
    
    convenience init(state: CallVanState, onMainButtonTapped: @escaping () -> Void, onCloseButtonTapped: (()->Void)? = nil) {
        let titleText: String
        var subTitleLabel: UILabel? = nil
        let mainButtonText: String
        let closeButtonText: String
        switch state {
        case .참여하기:
            titleText = "해당 콜밴팟에 참여할까요?"
            mainButtonText = "예"
            closeButtonText = "아니요"
        case .참여취소:
            titleText = "해당 콜밴팟 참여를 취소할까요?"
            mainButtonText = "예"
            closeButtonText = "아니요"
        case .마감하기:
            titleText = "해당 콜밴팟 모집을 마감할까요?"
            mainButtonText = "예"
            closeButtonText = "아니요"
        case .재모집:
            titleText = "해당 콜밴팟을 다시 모집할까요?"
            mainButtonText = "예"
            closeButtonText = "아니요"
        case .이용완료:
            titleText = "이용 완료 상태로 변경할까요?"
            subTitleLabel = UILabel().then {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = UIFont.appFont(.pretendardRegular, size: 14).lineHeight * 0.6
                $0.attributedText = NSAttributedString(
                    string: "• 콜밴 이용(탑승, 정산)이 모두 완료된 뒤 눌러야 합니다.\n• 완료 시 대화 내역이 삭제되며, 되돌릴 수 없습니다.",
                    attributes: [
                        .font : UIFont.appFont(.pretendardRegular, size: 14),
                        .foregroundColor : UIColor.appColor(.neutral600),
                        .paragraphStyle : paragraphStyle
                    ])
                $0.numberOfLines = 2
            }
            mainButtonText = "예"
            closeButtonText = "아니요"
        case .모집마감:
            titleText = ""
            mainButtonText = ""
            closeButtonText = ""
        }
        
        self.init(titleText: titleText, subTitleLabel: subTitleLabel, mainButtonText: mainButtonText, closeButtonText: closeButtonText, onMainButtonTapped: onMainButtonTapped, onCloseButtonTapped: onCloseButtonTapped)
    }
}

final class CallVanBottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    private let titleText: String
    private let mainButtonText: String
    private let closeButtonText: String
    private let onMainButtonTapped: ()->Void
    private let onCloseButtonTapped: (()->Void)?
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let subTitleLabel: UILabel?
    private let topSeparatorView = UIView()
    private let mainButton = UIButton()
    private let closeButton = UIButton()
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initializer
    init(
        titleText: String,
        subTitleLabel: UILabel?,
        mainButtonText: String,
        closeButtonText: String,
        onMainButtonTapped: @escaping () -> Void,
        onCloseButtonTapped: (()->Void)? = nil
    ) {
        self.titleText = titleText
        self.subTitleLabel = subTitleLabel
        self.mainButtonText = mainButtonText
        self.closeButtonText = closeButtonText
        self.onMainButtonTapped = onMainButtonTapped
        self.onCloseButtonTapped = onCloseButtonTapped
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
        setAddTargets()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.text = titleText
            $0.font = UIFont.appFont(.pretendardBold, size: 18)
            $0.textColor = UIColor.appColor(.new500)
        }
        mainButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: mainButtonText,
                attributes: [
                    .font : UIFont.appFont(.pretendardBold, size: 18),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.cornerRadius = 12
        }
        closeButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: closeButtonText,
                attributes: [
                    .font : UIFont.appFont(.pretendardBold, size: 18),
                    .foregroundColor : UIColor.appColor(.neutral600)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 12
        }
        [topSeparatorView, bottomSeparatorView].forEach {
            $0.backgroundColor = UIColor.appColor(.neutral300)
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, topSeparatorView, mainButton, closeButton, bottomSeparatorView].forEach {
            view.addSubview($0)
        }
        
        if let subTitleLabel {
            view.addSubview(subTitleLabel)
        }
    }
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        topSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        if let subTitleLabel {
            subTitleLabel.snp.makeConstraints {
                $0.top.equalTo(topSeparatorView.snp.bottom).offset(16)
                $0.leading.equalTo(titleLabel)
            }
        }
        
        mainButton.snp.makeConstraints {
            $0.height.equalTo(49)
            if let subTitleLabel {
                $0.top.equalTo(subTitleLabel.snp.bottom).offset(16)
            } else {
                $0.top.equalTo(topSeparatorView.snp.bottom).offset(16)
            }
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        closeButton.snp.makeConstraints {
            $0.height.equalTo(49)
            $0.top.equalTo(mainButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(closeButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

extension CallVanBottomSheetViewController {
    
    private func setAddTargets() {
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func mainButtonTapped() {
        onMainButtonTapped()
        dismissView()
    }
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
        dismissView()
    }
}

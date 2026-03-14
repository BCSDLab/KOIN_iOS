//
//  CallVanDataTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanDataTableViewCell: UITableViewCell{
    
    // MARK: - Properties
    let threeCircleButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let reportButtonTappedPublisher = PassthroughSubject<Int, Never>()
    private var userId: Int?
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let profileImageView = UIImageView()
    private let nickNameLabel = UILabel()
    private let threeCircleButton = UIButton()
    private let threeCircleImageView = UIImageView()
    private let separatorView = UIView()
    private let reportButton = UIButton()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(participant: CallVanParticipant, shoudHideSepearatorView: Bool) {
        userId = participant.userId
        profileImageView.image = participant.profileImage
        nickNameLabel.text = participant.nickname
        threeCircleButton.isHidden = participant.isMe
        threeCircleImageView.isHidden = participant.isMe
        separatorView.isHidden = shoudHideSepearatorView
    }
    
    func closeReportButton() {
        UIView.animate(
            withDuration: 0.1,
            animations: { [weak self] in
                self?.threeCircleImageView.backgroundColor = UIColor.appColor(.neutral0)
                self?.reportButton.alpha = 0
            },
            completion: { [weak self] _ in
                self?.reportButton.isHidden = true
            }
        )
    }
}

extension CallVanDataTableViewCell {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointInButton = self.convert(point, to: reportButton)
        
        if !reportButton.isHidden,
           reportButton.bounds.contains(pointInButton) {
            return reportButton
        }
        return super.hitTest(point, with: event)
    }
}

extension CallVanDataTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
}

extension CallVanDataTableViewCell {
    
    private func setAddTargets() {
        threeCircleButton.addTarget(self, action: #selector(threeCircleButtonTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    @objc private func threeCircleButtonTapped() {
        threeCircleButtonTappedPublisher.send()
        
        if reportButton.isHidden == true {
            showReportButton()
        } else {
            closeReportButton()
        }
    }
    
    @objc private func reportButtonTapped() {
        if let userId {
            reportButtonTappedPublisher.send(userId)
        }
    }
    
    private func showReportButton() {
        reportButton.isHidden = false
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.threeCircleImageView.backgroundColor = UIColor.appColor(.neutral100)
                self?.reportButton.alpha = 1
            }
        )
    }
}

extension CallVanDataTableViewCell {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
     
    private func setUpStyles() {
        nickNameLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 16)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        threeCircleImageView.do {
            $0.image = UIImage.appImage(asset: .callVanThreeCircle)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 4
        }
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
        reportButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage.appImage(asset: .siren)?.withTintColor(UIColor.appColor(.neutral600), renderingMode: .alwaysTemplate)
            configuration.attributedTitle = AttributedString("신고하기", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.neutral600)]))
            configuration.imagePadding = 4
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.cornerRadius = 4
            $0.layer.applySketchShadow(color: UIColor.black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
            $0.clipsToBounds = true
            $0.layer.masksToBounds = false
        }
        reportButton.do {
            $0.isHidden = true
            $0.alpha = 0
        }
    }
    
    private func setUpLayouts() {
        [profileImageView, nickNameLabel, threeCircleButton, threeCircleImageView, separatorView, reportButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        nickNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
        threeCircleButton.snp.makeConstraints {
            $0.edges.equalTo(threeCircleImageView).inset(-10)
        }
        threeCircleImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        reportButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.top.equalTo(threeCircleImageView.snp.bottom)
            $0.trailing.equalTo(threeCircleImageView)
        }
    }
}

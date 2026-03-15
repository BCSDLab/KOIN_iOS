//
//  CallVanListCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit
import Combine
import Then
import SnapKit

final class CallVanListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let mainButtonTappedPublisher = PassthroughSubject<Int, Never>()
    let subButtonTappedPublisher = PassthroughSubject<Int, Never>()
    let chatButtonTappedPublisher = PassthroughSubject<Int, Never>()
    let callButtonTappedPublisher = PassthroughSubject<Void, Never>()
    var subscriptions: Set<AnyCancellable> = []
    private var postId: Int = 0
    
    // MARK: - UI Components
    private let routeImageLayoutGuide = UILayoutGuide()
    private let routeImageView = UIImageView()
    private let departureLabel = UILabel()
    private let destinationLabel = UILabel()
    
    private let labelsStackView = UIStackView()
    private let dateLabel = UILabel()
    private let dayLabel = UILabel()
    private let timeLabel = UILabel()
    private let separatorLabel = UILabel()
    private let peopleImageView = UIImageView()
    private let peopleCountLabel = UILabel()
    
    private let mainButton = CallVanButton()
    private let subButton = CallVanButton()
    private let callVanButtonStackView = UIStackView()
    
    private let chatButton = UIButton()
    private let callButton = UIButton()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    // MARK: - Public
    func configure(_ post: CallVanListPost) {
        
        self.postId = post.postId
        
        departureLabel.do {
            $0.text = "출발: " + post.departure
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        destinationLabel.do {
            $0.text = "도착: " + post.arrival
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        dateLabel.do {
            $0.text = post.departureDate
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        dayLabel.do {
            $0.text = post.departureDay
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        timeLabel.do {
            $0.text = post.departureTime
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        peopleCountLabel.do {
            $0.text = "\(post.currentParticipants)/\(post.maxParticipants)"
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        
        mainButton.configure(state: post.mainState)
        if let subState = post.subState {
            subButton.configure(state: subState)
            subButton.isHidden = false
        } else {
            subButton.isHidden = true
        }
        
        chatButton.isHidden = !post.showChatButton
        callButton.isHidden = !post.showCallButton
    }
}

extension CallVanListCollectionViewCell {
    
    private func configureView() {
        setUpLayouts()
        setUpStyles()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        contentView.backgroundColor = UIColor.appColor(.neutral0)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        
        routeImageView.do {
            $0.image = UIImage.appImage(asset: .callVanRoute)
        }
        
        labelsStackView.do {
            $0.axis = .horizontal
            $0.setCustomSpacing(2, after: dateLabel)
            $0.setCustomSpacing(4, after: dayLabel)
            $0.setCustomSpacing(8, after: timeLabel)
            $0.setCustomSpacing(8, after: separatorLabel)
            $0.setCustomSpacing(4, after: peopleImageView)
            $0.alignment = .center
        }
        
        separatorLabel.do {
            $0.text = "|"
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        peopleImageView.do {
            $0.image = UIImage.appImage(asset: .callVanListPeople)
        }
        
        callVanButtonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
        }
        
        chatButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanChat), for: .normal)
        }
        callButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanCall), for: .normal)
        }
    }
    
    private func setUpLayouts() {
        [dateLabel, dayLabel, timeLabel, separatorLabel, peopleImageView, peopleCountLabel].forEach {
            labelsStackView.addArrangedSubview($0)
        }
        [mainButton, subButton].forEach {
            callVanButtonStackView.addArrangedSubview($0)
        }
        [routeImageView, departureLabel, destinationLabel, labelsStackView, callVanButtonStackView, chatButton, callButton].forEach {
            contentView.addSubview($0)
        }
        
        [routeImageLayoutGuide].forEach {
            contentView.addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        routeImageLayoutGuide.snp.makeConstraints {
            $0.top.equalTo(departureLabel)
            $0.bottom.equalTo(destinationLabel)
        }
        routeImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalTo(routeImageLayoutGuide)
        }
        departureLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.leading.equalTo(routeImageView.snp.trailing).offset(8)
            $0.top.equalToSuperview().offset(16)
        }
        destinationLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.leading.equalTo(routeImageView.snp.trailing).offset(8)
            $0.top.equalTo(departureLabel.snp.bottom).offset(4)
            $0.trailing.lessThanOrEqualTo(callVanButtonStackView.snp.leading).offset(-8)
        }
        labelsStackView.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(destinationLabel.snp.bottom).offset(4)
        }
        callVanButtonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-16.5)
        }
        peopleImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        chatButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.trailing.equalToSuperview().offset(-24)
        }
        callButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
}

extension CallVanListCollectionViewCell {
    
    private func setAddTargets() {
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        subButton.addTarget(self, action: #selector(subButtonTapped), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
    }
    
    @objc private func mainButtonTapped() {
        mainButtonTappedPublisher.send(postId)
    }
    @objc private func subButtonTapped() {
        subButtonTappedPublisher.send(postId)
    }
    @objc private func chatButtonTapped() {
        chatButtonTappedPublisher.send(postId)
    }
    @objc private func callButtonTapped() {
        callButtonTappedPublisher.send()
    }
}

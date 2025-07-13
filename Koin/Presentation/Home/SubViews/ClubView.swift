//
//  ClubView.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

import Combine
import UIKit

final class ClubView: UIView {
    
    private var subscriptions: Set<AnyCancellable> = []
    let clubListButtonPublisher = PassthroughSubject<Void, Never>()
    let clubCategoryPublisher = PassthroughSubject<Int, Never>()
    let hotClubButtonPublisher = PassthroughSubject<Int, Never>()
    private var hotClubId = 0
    
    // MARK: - UI Components
    
    private let nameLabel = UILabel().then {
        $0.text = "동아리"
    }
    
    private let chevronButton = UIButton().then {
        $0.setImage(UIImage(named: "chevronRightBlue"), for: .normal)
        $0.isHidden = true
    }
    
    private let clubCollctionView = ClubCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then{ _ in}).then {
        $0.isHidden = true
    }
    
    private let hotClubButton = UIButton().then {
        $0.isHidden = true
    }
    
    private let hotClubImageView = UIImageView()
    
    private let hotClubLabel = UILabel().then {
        $0.text = "인기 동아리"
    }
    
    private let hotClubSubLabel = UILabel().then {
        $0.text = "바로가기"
    }
    
    private let hotClubChevronImageView = UIImageView().then {
        $0.image = .appImage(asset: .arrowRight)?.withTintColor(.appColor(.neutral800), renderingMode: .alwaysOriginal)
        
    }
    ///
    private let clubListButton = UIButton().then {
        $0.isHidden = true
    }
    
    private let clubListImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .note)
    }
    
    private let clubListLabel = UILabel().then {
        $0.text = "동아리 목록"
    }
    
    private let clubListSubLabel = UILabel().then {
        $0.text = "바로가기"
    }
    
    private let clubListChevronImageView = UIImageView().then {
        $0.image = .appImage(asset: .arrowRight)?.withTintColor(.appColor(.neutral800), renderingMode: .alwaysOriginal)

    }

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        bind()
        chevronButton.addTarget(self, action: #selector(chevronButtonTapped), for: .touchUpInside)
        hotClubButton.addTarget(self, action: #selector(hotClubButtonTapped), for: .touchUpInside)
        clubListButton.addTarget(self, action: #selector(clubListButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func bind() {
        clubCollctionView.tapPublisher.sink { [weak self] id in
            self?.clubCategoryPublisher.send(id)
        }.store(in: &subscriptions)
    }
    
    func setupClubCategories(categories: [ClubCategory]) {
        clubCollctionView.setClubs(categories)
        clubCollctionView.isHidden = false
        clubCollctionView.snp.remakeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(clubCollctionView.calculateDynamicHeight())
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupHotClub(club: HotClubDTO) {
        hotClubImageView.loadImageWithSpinner(from: club.imageUrl)
        hotClubImageView.isHidden = false
        hotClubId = club.clubId
        chevronButton.isHidden = false
        hotClubButton.isHidden = false
        clubListButton.isHidden = false
        hotClubButton.snp.remakeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(self.snp.centerX).offset(-8)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview()
        }
    }

}

extension ClubView {
    @objc func chevronButtonTapped() {
        clubListButtonPublisher.send()
    }
    @objc func hotClubButtonTapped() {
        hotClubButtonPublisher.send(hotClubId)
    }
    @objc func clubListButtonTapped() {
        clubListButtonPublisher.send()
    }
}

// MARK: UI Settings

extension ClubView {
    private func setUpLayOuts() {
        [nameLabel, chevronButton, clubCollctionView, hotClubButton, clubListButton].forEach {
            self.addSubview($0)
        }
        [hotClubImageView, hotClubLabel, hotClubSubLabel, hotClubChevronImageView].forEach {
            hotClubButton.addSubview($0)
        }
        [clubListImageView, clubListLabel, clubListSubLabel, clubListChevronImageView].forEach {
            clubListButton.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        chevronButton.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(29)
        }
        clubCollctionView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(1)
        }
        hotClubButton.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(self.snp.centerX).offset(-8)
            $0.height.equalTo(64)
        }
        clubListButton.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.leading.equalTo(self.snp.centerX).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(64)
        }
        //
        hotClubImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(hotClubLabel.snp.leading).offset(-4)
            $0.size.equalTo(30)
        }
        hotClubLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }
        hotClubSubLabel.snp.makeConstraints {
            $0.top.equalTo(hotClubLabel.snp.bottom)
            $0.leading.equalTo(hotClubLabel)
            $0.height.equalTo(18)
        }
        hotClubChevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(27)
            $0.size.equalTo(15)
        }
        //
        clubListImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(clubListLabel.snp.leading).offset(-4)
            $0.size.equalTo(30)
        }
        clubListLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }
        clubListSubLabel.snp.makeConstraints {
            $0.top.equalTo(clubListLabel.snp.bottom)
            $0.leading.equalTo(clubListLabel)
            $0.height.equalTo(18)
        }
        clubListChevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(27)
            $0.size.equalTo(15)
        }
    }
    private func setUpComponents() {
        nameLabel.textColor = UIColor.appColor(.primary500)
        nameLabel.font = UIFont.appFont(.pretendardBold, size: 15)
        [hotClubLabel, clubListLabel].forEach {
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        }
        [hotClubSubLabel, clubListSubLabel].forEach {
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardRegular, size: 11)
        }
        [hotClubButton, clubListButton].forEach {
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpComponents()
    }
}


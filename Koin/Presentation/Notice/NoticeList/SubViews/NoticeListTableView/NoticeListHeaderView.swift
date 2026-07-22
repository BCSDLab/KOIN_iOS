//
//  NoticeListHeaderView.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine
import UIKit

final class NoticeListHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDto, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    let typeButtonPublisher = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let noticeKeywordCollectionView: NoticeKeywordCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        return NoticeKeywordCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    private let typeButton = UIButton().then {
        $0.isHidden = true
        var configuration = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)
        configuration.image = image
        var text = AttributedString("물품 전체")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        configuration.imagePlacement = .trailing
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.configuration = configuration
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        noticeKeywordCollectionView.keywordAddBtnTapPublisher.sink { [weak self] in
            self?.keywordAddBtnTapPublisher.send()
        }.store(in: &noticeKeywordCollectionView.subscriptions)
        noticeKeywordCollectionView.keywordTapPublisher.sink { [weak self] keyword in
            self?.keywordTapPublisher.send(keyword)
        }.store(in: &noticeKeywordCollectionView.subscriptions)
        noticeKeywordCollectionView.manageKeyWordBtnTapPublisher.sink { [weak self] in
            self?.manageKeyWordBtnTapPublisher.send()
        }.store(in: &noticeKeywordCollectionView.subscriptions)
        typeButton.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    @objc private func typeButtonTapped() {
        typeButtonPublisher.send()
    }
    
    
}

extension NoticeListHeaderView {
    func setText(type: LostItemType?) {
        let buttonText: String
        switch type {
        case .lost, .found: buttonText = "\(type?.description ?? "")물"
        case nil: buttonText = "물품 전체"
        }
        var configuration = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)
        configuration.image = image
        var text = AttributedString(buttonText)
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        configuration.imagePlacement = .trailing
        typeButton.backgroundColor = UIColor.appColor(.info200)
        typeButton.configuration = configuration
        typeButton.layer.cornerRadius = 12
        typeButton.layer.masksToBounds = true
    }
    func toggleButton(isHidden: Bool) {
        typeButton.isHidden = isHidden
    }

    
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], keywordIdx: Int) {
        noticeKeywordCollectionView.updateUserKeywordList(keywordList: keywordList, keywordIdx: keywordIdx)
    }
}

extension NoticeListHeaderView {
    
    private func setUpLayouts() {
        contentView.addSubview(noticeKeywordCollectionView)
        contentView.addSubview(typeButton)
    }
    
    private func setUpConstraints() {
        noticeKeywordCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(34)
        }
        typeButton.snp.makeConstraints {
            $0.top.equalTo(noticeKeywordCollectionView.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(96)
            $0.height.equalTo(32)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

//
//  LostItemDataTableViewContentCell.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class LostItemDataTableViewContentCell: UITableViewCell {
    
    // MARK: - Properties
    let imageTapPublisher = PassthroughSubject<IndexPath, Never>()
    let listButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let editButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let changeStateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let chatButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let reportButtonTappedPublisher = PassthroughSubject<Void, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fillProportionally
        $0.alignment = .fill
    }
    
    private let imageWrapperView = UIView()
    
    private let imageCollectionView = ShopSummaryImagesCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 63, height: 278)
        $0.minimumLineSpacing = 0
    }).then {
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private let pageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.pageIndicatorTintColor = UIColor.appColor(.neutral300)
        $0.currentPageIndicatorTintColor = UIColor.appColor(.primary400)
        $0.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        $0.isHidden = true
    }
    
    private let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.isHidden = true
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let councilLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        $0.textColor = UIColor.appColor(.neutral500)
        $0.numberOfLines = 3
        let text = "분실물 수령을 희망하시는 분은 재실 시간 내에\n학생회관 320호 총학생회 사무실로 방문해 주시기 바랍니다.\n재실 시간은 공지 사항을 참고해 주시기 바랍니다."
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "학생회관 320호 총학생회 사무실")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral700), range: range)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let changeStateView = UIView()
    
    private let changeStateLabel = UILabel().then {
        $0.text = "물건을 찾았나요?"
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
    }
    
    private let changeStateButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral400)
        $0.layer.cornerRadius = 11
        $0.clipsToBounds = true
    }
    private let changeStateCircleView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 1, blur: 4, spread: 0)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let buttonsView = UIView()
    
    private let listButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("목록", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.configuration = configuration
    }
    
    private let editButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("수정", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.configuration = configuration
    }
    private let deleteButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("삭제", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.configuration = configuration
    }
    private let chatButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("쪽지 보내기", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.image = .appImage(asset: .chat)
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        $0.configuration = configuration
    }
    private let reportButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .siren)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        $0.configuration = configuration
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        bind()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeState() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.changeStateButton.backgroundColor = .appColor(.primary500)
            self?.changeStateCircleView.transform = CGAffineTransform(translationX: 24, y: 0)
            self?.changeStateCircleView.layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    func configure(lostItemData: LostItemData?) {
        guard let lostItemData else { return }
        
        imageCollectionView.configure(orderImage: lostItemData.images.map {
            OrderImage(imageUrl: $0.imageUrl, isThumbnail: false)
        })
        imageCollectionView.isHidden = lostItemData.images.isEmpty
        
        pageControl.numberOfPages = lostItemData.images.count
        pageControl.isHidden = lostItemData.images.isEmpty || (lostItemData.images.count == 1)
        
        if lostItemData.images.count == 1 {
            imageCollectionView.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(7.5)
                $0.height.equalTo(278)
            }
        }
        if 1 < lostItemData.images.count {
            contentStackView.setCustomSpacing(8, after: imageWrapperView)
            imageCollectionView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-38)
            }
        }
        
        contentLabel.attributedText = NSAttributedString(string: "\(lostItemData.content)", attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 14),
            .foregroundColor : UIColor.appColor(.neutral800),
            .paragraphStyle : NSMutableParagraphStyle().then { $0.lineSpacing = 1.6 }
        ])
        contentLabel.isHidden = lostItemData.content != nil
        
        councilLabel.isHidden = !lostItemData.isCouncil
        
        changeStateView.isHidden = (lostItemData.isMine && !lostItemData.isFound) ? false : true
        changeStateView.isHidden = (lostItemData.isMine && !lostItemData.isFound) ? false : true
    
        editButton.isHidden = lostItemData.isMine ? false : true
        deleteButton.isHidden = lostItemData.isMine ? false : true
        
        chatButton.isHidden = lostItemData.isMine
        
        reportButton.isHidden = (lostItemData.isMine || lostItemData.isCouncil)
        
        if lostItemData.isCouncil {
            chatButton.snp.remakeConstraints {
                $0.top.bottom.trailing.equalToSuperview()
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension LostItemDataTableViewContentCell {
    
    private func setAddTargets() {
        listButton.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        changeStateButton.addTarget(self, action: #selector(changeStateButtonTapped), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        imageCollectionView.didScrollOutputSubject.sink { [weak self] page in
            guard let self else { return }
            pageControl.currentPage = page
        }.store(in: &subscriptions)
        
        imageCollectionView.didTapThumbnailPublisher.sink { [weak self] indexPath in
            self?.imageTapPublisher.send(indexPath)
        }.store(in: &subscriptions)
    }
    
    @objc private func listButtonTapped() {
        listButtonTappedPublisher.send()
    }
    @objc private func deleteButtonTapped() {
        deleteButtonTappedPublisher.send()
    }
    @objc private func editButtonTapped() {
        editButtonTappedPublisher.send()
    }
    @objc private func changeStateButtonTapped() {
        if (changeStateButton.backgroundColor != UIColor.appColor(.primary500)) {
            changeStateButtonTappedPublisher.send()
        }
    }
    @objc private func chatButtonTapped() {
        chatButtonTappedPublisher.send()
    }
    @objc private func reportButtonTapped() {
        reportButtonTappedPublisher.send()
    }
}

extension LostItemDataTableViewContentCell {
    
    private func configureButtons() {
        [listButton, editButton, deleteButton, chatButton, reportButton].forEach {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 4
            $0.backgroundColor = .appColor(.neutral300)
            $0.tintColor = .appColor(.neutral600)
        }
    }
    
    private func setUpLayouts() {
        [changeStateLabel, changeStateButton, changeStateCircleView].forEach {
            changeStateView.addSubview($0)
        }
        [listButton, editButton, deleteButton, chatButton, reportButton].forEach {
            buttonsView.addSubview($0)
        }
        [imageCollectionView, pageControl].forEach {
            imageWrapperView.addSubview($0)
        }
        [imageWrapperView, contentLabel, councilLabel, changeStateView, buttonsView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        [contentStackView, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        imageCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(7.5).priority(999)
            $0.height.equalTo(278)
            $0.bottom.equalToSuperview().offset(0)
        }
        pageControl.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        changeStateLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(22)
            $0.trailing.equalTo(changeStateButton.snp.leading).offset(-4)
        }
        changeStateButton.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(46)
        }
        changeStateCircleView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(changeStateButton.snp.leading).offset(3)
        }
        
        [listButton, editButton, deleteButton, chatButton, reportButton].forEach {
            $0.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
            }
        }
        listButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
        editButton.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
        }
        reportButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
        chatButton.snp.makeConstraints {
            $0.trailing.equalTo(reportButton.snp.leading).offset(-8)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(separatorView.snp.top).offset(-16).priority(999)
        }
        councilLabel.snp.makeConstraints {
            $0.height.equalTo(89)
        }
        buttonsView.snp.makeConstraints {
            $0.height.equalTo(32)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
    
    private func configureView() {
        configureButtons()
        setUpLayouts()
        setUpConstraints()
        selectionStyle = .none
    }
}

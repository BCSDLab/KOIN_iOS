//
//  NewBannerViewController.swift
//  koin
//
//  Created by 홍기정 on 6/20/26.
//

import SnapKit
import Then
import UIKit

final class NewBannerViewController: UIViewController {
    
    // MARK: - Properties
    private let onBannerTap: (Banner) -> Void
    private let onLogEvent: (EventLabelType, EventParameter.EventCategory, Any) -> Void
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let noShowButton = UIButton()
    private let closeButton = UIButton()
    private lazy var collectionView = NewBannerCollectionView(
        onBannerTap: { [weak self] banner in
            self?.onBannerTap(banner)
        },
        onPageChanged: { [weak self] index, totalCount in
            self?.setCountLabel(index: index, totalCount: totalCount)
        },
        onBannerSwiped: { [weak self] banner in
            self?.onLogEvent(EventParameter.EventLabel.Campus.mainNextModal, .swipe, banner.title)
        }
    )
    private let countLabel = UILabel()

    // MARK: - Initializer
    init(
        onBannerTap: @escaping (Banner) -> Void,
        onLogEvent: @escaping (EventLabelType, EventParameter.EventCategory, Any) -> Void
    ) {
        self.onBannerTap = onBannerTap
        self.onLogEvent = onLogEvent
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

    // MARK: - Public
    func setBanners(_ banners: [Banner]) {
        collectionView.setBanners(banners)
    }
}

extension NewBannerViewController {
    
    private func setAddTargets() {
        noShowButton.addTarget(self, action: #selector(noShowButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func noShowButtonTapped() {
        dismiss(animated: true)
        UserDefaults.standard.set(Date(), forKey: "noShowBanner")
        
        if let title = collectionView.currentTitle {
            onLogEvent(EventParameter.EventLabel.Campus.mainModalHide7d, .click, title)
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
        
        if let title = collectionView.currentTitle {
            onLogEvent(EventParameter.EventLabel.Campus.mainModalClose, .click, title)
        }
    }
}

extension NewBannerViewController {
    
    private func setCountLabel(index: Int, totalCount: Int) {
        let text = "\(index + 1)/\(totalCount)"
        let attributedString = NSMutableAttributedString(string: text)
        guard let slashRange = text.range(of: "/") else {
            countLabel.attributedText = attributedString
            return
        }

        let slashLocation = text.distance(from: text.startIndex, to: slashRange.lowerBound)
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.white,
            range: NSRange(location: 0, length: slashLocation)
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.appColor(.neutral400),
            range: NSRange(location: slashLocation, length: text.count - slashLocation)
        )
        countLabel.attributedText = attributedString
    }
}


extension NewBannerViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        noShowButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        noShowButton.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        noShowButton.setTitle("일주일 동안 그만 보기", for: .normal)
        
        closeButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        closeButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        closeButton.setTitle("닫기", for: .normal)
        
        countLabel.backgroundColor = .black.withAlphaComponent(0.5)
        countLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        countLabel.textAlignment = .center
        countLabel.layer.cornerRadius = 8
        countLabel.layer.masksToBounds = true
    }
    
    private func setUpLayouts() {
        view.addSubview(contentView)
        [noShowButton, closeButton, collectionView, countLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        noShowButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(22.5)
            $0.width.equalTo(120)
            $0.height.equalTo(22)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().offset(-22.5)
            $0.width.equalTo(25)
            $0.height.equalTo(22)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(13)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(293)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.top).offset(8)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
    }
}

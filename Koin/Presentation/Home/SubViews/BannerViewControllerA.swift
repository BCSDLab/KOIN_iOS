//
//  BannerViewControllerA.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class BannerViewControllerA: UIViewController {
    
    // MARK: - properties
    private var subscriptions: Set<AnyCancellable> = []
    let bannerTapPublisher = PassthroughSubject<Banner, Never>()
    
    private let whiteView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let noShowButton = UIButton().then {
        $0.setTitle("일주일 동안 그만 보기", for: .normal)
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
    }
    
    private let collectionView: BannerCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = BannerCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let countLabel = UILabel()
    
    
    // MARK: - UI Components
   

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        noShowButton.addTarget(self, action: #selector(noShowButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    func setBanners(banners: [Banner]) {
        collectionView.setBanners(banners)
        setCountLabel(index: 0, totalCount: banners.count)
    }

    private func bind() {
        collectionView.scrollPublisher.sink { [weak self] item in
            self?.setCountLabel(index: item.0, totalCount: item.1)
        }.store(in: &subscriptions)
        
        collectionView.tapPublisher.sink { [weak self] item in
            self?.bannerTapPublisher.send(item)
        }.store(in: &subscriptions)
    }
    
    private func setCountLabel(index: Int, totalCount: Int) {
        let current = index + 1
        let total = totalCount

        let text = "\(current)/\(total)"
        let attributedString = NSMutableAttributedString(string: text)


        if let slashRange = text.range(of: "/") {
            let slashLocation = text.distance(from: text.startIndex, to: slashRange.lowerBound)

            attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: slashLocation))
            attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral400), range: NSRange(location: slashLocation, length: text.count - slashLocation))
        }

        countLabel.attributedText = attributedString
    }
}

extension BannerViewControllerA {
    @objc private func noShowButtonTapped() {
        UserDefaults.standard.set(Date(), forKey: "noShowBanner")
        dismiss(animated: true)
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension BannerViewControllerA {
    
    private func setUpLayOuts() {
       
        [whiteView].forEach {
            view.addSubview($0)
        }
        [noShowButton, closeButton, collectionView, countLabel].forEach {
            whiteView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        whiteView.snp.makeConstraints {
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
            $0.bottom.equalToSuperview().offset(-48)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.top).offset(8)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
    }
    
    private func setUpComponents() {
        noShowButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        noShowButton.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        closeButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        closeButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        whiteView.layer.masksToBounds = true
        whiteView.layer.cornerRadius = 8
        countLabel.backgroundColor = .black.withAlphaComponent(0.5)
        countLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        countLabel.textAlignment = .center
        countLabel.layer.cornerRadius = 8
        countLabel.layer.masksToBounds = true
    }

    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpComponents()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}

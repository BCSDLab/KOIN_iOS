//
//  BannerViewControllerB.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class BannerViewControllerB: UIViewController {
    
    // MARK: - properties
    private var subscriptions: Set<AnyCancellable> = []
    let bannerTapPublisher = PassthroughSubject<Banner, Never>()
    private let viewModel: HomeViewModel
    
    private let whiteView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let noShowButton = UIButton().then {
        $0.setTitle("일주일 동안 그만 보기", for: .normal)
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
    }
    
    private lazy var collectionView: BannerCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = BannerCollectionView(frame: .zero, collectionViewLayout: flowLayout, viewModel: viewModel)
        return collectionView
    }()
    
    private let countLabel = UILabel()
    
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

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

extension BannerViewControllerB {
    @objc private func noShowButtonTapped() {
        viewModel.logAnalyticsEventUseCase.logEvent(name: "CAMPUS", label: "main_modal_hide_7d", value: collectionView.showingBanner, category: "click")
        UserDefaults.standard.set(Date(), forKey: "noShowBanner")
        dismiss(animated: true)
    }
    @objc private func closeButtonTapped() {
        viewModel.logAnalyticsEventUseCase.logEvent(name: "CAMPUS", label: "main_modal_close", value: collectionView.showingBanner, category: "click")
        dismiss(animated: true)
    }
}

extension BannerViewControllerB {
    
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
            $0.centerX.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(336)
        }
        collectionView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(256)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.top).offset(10)
            $0.trailing.equalToSuperview().offset(-28)
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
        noShowButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalTo(view.snp.centerX).offset(35)
            $0.height.equalTo(46)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(17)
            $0.leading.equalTo(noShowButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(46)
        }
    }
    
    private func setUpComponents() {
        noShowButton.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        noShowButton.setTitleColor(UIColor.appColor(.primary500), for: .normal)
        noShowButton.layer.masksToBounds = true
        noShowButton.layer.cornerRadius = 8
        noShowButton.layer.borderColor = UIColor.appColor(.primary400).cgColor
        noShowButton.layer.borderWidth = 1
        
        closeButton.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = 8
        closeButton.backgroundColor = UIColor.appColor(.primary500)
        
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

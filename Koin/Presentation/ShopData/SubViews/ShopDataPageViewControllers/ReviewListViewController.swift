//
//  ReviewListViewController.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Combine
import Then
import UIKit

final class ReviewListViewController: UIViewController {
    
    // MARK: - Properties
    let viewControllerHeightPublisher = PassthroughSubject<CGFloat, Never>()
    let fetchStandardPublisher = PassthroughSubject<(ReviewSortType?, Bool?), Never>()
    let deleteReviewPublisher = PassthroughSubject<(Int, Int), Never>()
    let reviewCountFetchRequestPublisher = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel = ReviewListViewModel()
    private let inputSubject: PassthroughSubject<ReviewListViewModel.Input, Never> = .init()
    
    // MARK: - UI Components
    
    private let writeReviewButton = UIButton().then {
        $0.setTitleColor(UIColor.appColor(.primary600), for: .normal)
        $0.layer.borderColor = UIColor.appColor(.primary600).cgColor
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1.0
        $0.setTitle("리뷰 작성하기", for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let totalScoreLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 32)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let totalScoreView = ScoreView().then {
        $0.settings.starSize = 16
        $0.settings.starMargin = 2
        $0.settings.fillMode = .precise
        $0.settings.updateOnTouch = false
    }
    
    private let scoreChartCollectionView: ScoreChartCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        let collectionView = ScoreChartCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let reviewListCollectionView: ReviewListCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        let collectionView = ReviewListCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let nonReviewImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .nonReview)
        $0.isHidden = true
    }
    
    private let reviewLoginModalViewController = ReviewLoginModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let deleteReviewModalViewController = DeleteReviewModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        writeReviewButton.addTarget(self, action: #selector(writeReviewButtonTapped), for: .touchUpInside)
        print(KeyChainWorker.shared.read(key: .access))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reviewCountFetchRequestPublisher.send(())
    }
    
    func setReviewList(_ review: [Review], _ shopId: Int) {
        reviewListCollectionView.setReviewList(review)
        viewModel.shopId = shopId
        let height = reviewListCollectionView.calculateDynamicHeight()
        reviewListCollectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        nonReviewImageView.isHidden = !review.isEmpty
        reviewListCollectionView.isHidden = review.isEmpty
        if review.isEmpty {
            viewControllerHeightPublisher.send(nonReviewImageView.frame.height + 230)
        } else {
            viewControllerHeightPublisher.send(height + writeReviewButton.frame.height + scoreChartCollectionView.frame.height + 50)
        }
        
    }
    
    func setReviewStatistics(statistics: StatisticsDTO) {
        totalScoreLabel.text = "\(statistics.averageRating)"
        totalScoreView.rating = statistics.averageRating
        scoreChartCollectionView.setStatistics(statistics)
    }
    
    private func bind() {
        
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case let .updateLoginStatus(isLogined):
                if isLogined { self.navigateToWriteReview() }
                else { self.present(self.reviewLoginModalViewController, animated: true, completion: nil) }
            }
        }.store(in: &cancellables)
        
        reviewListCollectionView.myReviewButtonPublisher.sink { [weak self] isMine in
            self?.fetchStandardPublisher.send((nil, isMine))
        }.store(in: &cancellables)
        
        reviewListCollectionView.sortTypeButtonPublisher.sink { [weak self] type in
            self?.fetchStandardPublisher.send((type, nil))
        }.store(in: &cancellables)
        
        reviewListCollectionView.deleteButtonPublisher.sink { [weak self] parameter in
            guard let self = self else { return }
            self.viewModel.deleteParameter = parameter
            self.present(self.deleteReviewModalViewController, animated: true, completion: nil)
        }.store(in: &cancellables)
        
        reviewLoginModalViewController.loginButtonPublisher.sink { [weak self] in
            self?.navigateToLogin()
        }.store(in: &cancellables)
        
        deleteReviewModalViewController.deleteButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.deleteReviewPublisher.send(self.viewModel.deleteParameter)
        }.store(in: &cancellables)
        
        reviewListCollectionView.modifyButtonPublisher.sink { [weak self] parameter in
            let shopRepository = DefaultShopRepository(service: DefaultShopService())
            let postReviewUseCase = DefaultPostReviewUseCase(shopRepository: shopRepository)
            let modifyReviewUseCase = DefaultModifyReviewUseCase(shopRepository: shopRepository)
            let fetchShopReviewUseCase = DefaultFetchShopReviewUseCase(shopRepository: shopRepository)
            let uploadFileUseCase = DefaultUploadFileUseCase(shopRepository: shopRepository)
            
            let shopReviewViewController = ShopReviewViewController(viewModel: ShopReviewViewModel(postReviewUseCase: postReviewUseCase, modifyReviewUseCase: modifyReviewUseCase, fetchShopReviewUseCase: fetchShopReviewUseCase, uploadFileUseCase: uploadFileUseCase, reviewId: parameter.0, shopId: parameter.1))
            shopReviewViewController.navigationController?.title = "리뷰 수정하기"
            self?.navigationController?.pushViewController(shopReviewViewController, animated: true)
        }.store(in: &cancellables)
        
        reviewListCollectionView.reportButtonPublisher.sink { [weak self] parameter in
            let viewController = ShopReviewReportViewController(viewModel: ShopReviewReportViewModel(reportReviewReviewUseCase: DefaultReportReviewUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService())), reviewId: parameter.0, shopId: parameter.1))
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &cancellables)
    }
    
}

extension ReviewListViewController {
    
    @objc private func writeReviewButtonTapped() {
        inputSubject.send(.checkLogin)
    }
    
    private func navigateToLogin() {
        let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        loginViewController.title = "로그인"
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    private func navigateToWriteReview() {
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let postReviewUseCase = DefaultPostReviewUseCase(shopRepository: shopRepository)
        let modifyReviewUseCase = DefaultModifyReviewUseCase(shopRepository: shopRepository)
        let fetchShopReviewUseCase = DefaultFetchShopReviewUseCase(shopRepository: shopRepository)
        let uploadFileUseCase = DefaultUploadFileUseCase(shopRepository: shopRepository)
        
        
        let shopReviewViewController = ShopReviewViewController(viewModel: ShopReviewViewModel(postReviewUseCase: postReviewUseCase, modifyReviewUseCase: modifyReviewUseCase, fetchShopReviewUseCase: fetchShopReviewUseCase, uploadFileUseCase: uploadFileUseCase, shopId: viewModel.shopId))
        shopReviewViewController.navigationController?.title = "리뷰 작성하기"
        navigationController?.pushViewController(shopReviewViewController, animated: true)
    }
}

extension ReviewListViewController {
    private func setUpLayOuts() {
        [writeReviewButton, totalScoreLabel, totalScoreView, scoreChartCollectionView, reviewListCollectionView, nonReviewImageView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        writeReviewButton.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(12)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.trailing.equalTo(view.snp.trailing).offset(-16)
            $0.height.equalTo(40)
        }
        
        totalScoreLabel.snp.makeConstraints {
            $0.top.equalTo(writeReviewButton.snp.bottom).offset(26)
            $0.leading.equalTo(view.snp.leading).offset(45)
        }
        
        totalScoreView.snp.makeConstraints {
            $0.top.equalTo(totalScoreLabel.snp.bottom).offset(4)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.width.equalTo(88)
            $0.height.equalTo(16)
        }
        
        scoreChartCollectionView.snp.makeConstraints {
            $0.top.equalTo(writeReviewButton.snp.bottom).offset(14)
            $0.leading.equalTo(totalScoreView.snp.trailing).offset(14)
            $0.trailing.equalTo(view.snp.trailing)
            $0.height.equalTo(95)
        }
        
        reviewListCollectionView.snp.makeConstraints {
            $0.top.equalTo(scoreChartCollectionView.snp.bottom).offset(14)
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
            $0.height.equalTo(1)
        }
        
        nonReviewImageView.snp.makeConstraints {
            $0.top.equalTo(scoreChartCollectionView.snp.bottom).offset(95)
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(244)
            $0.height.equalTo(262)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
    
}

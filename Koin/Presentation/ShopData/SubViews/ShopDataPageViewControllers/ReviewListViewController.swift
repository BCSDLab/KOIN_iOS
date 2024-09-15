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
    let scrollFetchPublisher = PassthroughSubject<Int, Never>()
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
    
    private let reviewWriteLoginModalViewController = ReviewLoginModalViewController(message: "작성").then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let reviewReportLoginModalViewController = ReviewLoginModalViewController(message: "신고").then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let deleteReviewModalViewController = DeleteReviewModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private var shopReviewReportViewController: ShopReviewReportViewController? {
        didSet {
            shopReviewReportViewController?.reviewInfoPublisher.sink { [weak self] tuple in
                self?.reviewListCollectionView.disappearReview(tuple.0, shopId: tuple.1)
            }.store(in: &cancellables)
        }
    }
    
    private var shopReviewViewController: ShopReviewViewController? {
        didSet {
            shopReviewViewController?.writeCompletePublisher.sink { [weak self] tuple in
                let isPost = tuple.0
                if isPost {
                    self?.fetchStandardPublisher.send((.latest, false))
                } else {
                    if let reviewId = tuple.1 {
                        self?.reviewListCollectionView.modifySuccess(reviewId, tuple.2)
                    }
                }
            }.store(in: &cancellables)
        }
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
    }
    
    func setReviewList(_ review: [Review], _ shopId: Int, _ shopName: String, _ fetchStandard: ReviewSortType, _ isMine: Bool, _ currentPage: Int, _ totalPage: Int, _ disappear: Bool) {
        if disappear {
            reviewListCollectionView.resetReviewList()
        }
        reviewListCollectionView.addReviewList(review)
        viewModel.shopId = shopId
        viewModel.shopName = shopName
        changeCollectionViewHeight(reviewCount: review.count)
        reviewListCollectionView.setHeader(fetchStandard, isMine)
        viewModel.fetchLock = false
        viewModel.currentPage = currentPage
        viewModel.totalPage = totalPage
        print("\(currentPage) \(totalPage)")
    }
    
    func setReviewStatistics(statistics: StatisticsDTO) {
        totalScoreLabel.text = "\(statistics.averageRating)"
        totalScoreView.rating = statistics.averageRating
        scoreChartCollectionView.setStatistics(statistics)
    }
    
    func disappearReview(_ reviewId: Int, _ shopId: Int) {
        reviewListCollectionView.disappearReview(reviewId, shopId: shopId)
    }
    
    func scrollViewHeightChanged(point: CGPoint) {
        if let visibleIndexPath = reviewListCollectionView.indexPathForItem(at: point) {
            if viewModel.currentPage < viewModel.totalPage && !viewModel.fetchLock && reviewListCollectionView.reviewList.count - 6 < visibleIndexPath.row {
                viewModel.fetchLock = true
                scrollFetchPublisher.send(viewModel.currentPage + 1)
            }
        }
    }
    
    private func changeCollectionViewHeight(reviewCount: Int) {
        let height = reviewListCollectionView.calculateDynamicHeight()
        reviewListCollectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        nonReviewImageView.isHidden = reviewCount != 0
        // ???: 이거 숨기는게 맞긴한데 이거 숨기면 플로우가 어색하다. 회의 때 말해보기
        //  reviewListCollectionView.isHidden = review.isEmpty
        if reviewCount == 0 {
            viewControllerHeightPublisher.send(nonReviewImageView.frame.height + 400)
        } else {
            viewControllerHeightPublisher.send(height + writeReviewButton.frame.height + scoreChartCollectionView.frame.height + 50)
        }
    }
    
    private func bind() {
        
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case let .updateLoginStatus(isLogined, parameter):
                if !isLogined {
                    if let parameter {
                        self.present(self.reviewReportLoginModalViewController, animated: true, completion: nil)
                    } else {
                        self.present(self.reviewWriteLoginModalViewController, animated: true, completion: nil)
                    }
                } else {
                    if let parameter {
                        self.navigateToReportReview(parameter: parameter)
                    } else {
                        self.navigateToWriteReview()
                    }
                }
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
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewDelete, .click, self.viewModel.shopName))
            self.present(self.deleteReviewModalViewController, animated: true, completion: nil)
        }.store(in: &cancellables)
        
        reviewWriteLoginModalViewController.loginButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewWriteLogin, .click, self?.viewModel.shopName ?? ""))
            self?.navigateToLogin()
        }.store(in: &cancellables)
        
        reviewWriteLoginModalViewController.cancelButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewWriteCancel, .click, self?.viewModel.shopName ?? ""))
        }.store(in: &cancellables)
        
        deleteReviewModalViewController.deleteButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewDeleteDone, .click, self.viewModel.shopName))
            self.deleteReviewPublisher.send(self.viewModel.deleteParameter)
        }.store(in: &cancellables)
        
        deleteReviewModalViewController.cancelButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewDeleteCancel, .click, self.viewModel.shopName))
        }.store(in: &cancellables)
        
        reviewReportLoginModalViewController.loginButtonPublisher.sink { [weak self] in
            self?.navigateToLogin()
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewReportLogin, .click, self?.viewModel.shopName ?? ""))
        }.store(in: &cancellables)
        
        reviewReportLoginModalViewController.cancelButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewReportCancel, .click, self?.viewModel.shopName ?? ""))
        }.store(in: &cancellables)
        
        reviewListCollectionView.modifyButtonPublisher.sink { [weak self] parameter in
            let shopRepository = DefaultShopRepository(service: DefaultShopService())
            let postReviewUseCase = DefaultPostReviewUseCase(shopRepository: shopRepository)
            let modifyReviewUseCase = DefaultModifyReviewUseCase(shopRepository: shopRepository)
            let fetchShopReviewUseCase = DefaultFetchShopReviewUseCase(shopRepository: shopRepository)
            let uploadFileUseCase = DefaultUploadFileUseCase(shopRepository: shopRepository)
            let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: shopRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
            let shopReviewViewController = ShopReviewViewController(viewModel: ShopReviewViewModel(postReviewUseCase: postReviewUseCase, modifyReviewUseCase: modifyReviewUseCase, fetchShopReviewUseCase: fetchShopReviewUseCase, uploadFileUseCase: uploadFileUseCase, fetchShopDataUseCase: fetchShopDataUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase, reviewId: parameter.0, shopId: parameter.1, shopName: self?.viewModel.shopName ?? ""))
            shopReviewViewController.title = "리뷰 수정하기"
            self?.shopReviewViewController = shopReviewViewController
            if let viewController = self?.shopReviewViewController {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }.store(in: &cancellables)
        
        reviewListCollectionView.heightChangePublisher.sink { [weak self] count in
            self?.changeCollectionViewHeight(reviewCount: count)
        }.store(in: &cancellables)
        
        reviewListCollectionView.reportButtonPublisher.sink { [weak self] parameter in
            self?.inputSubject.send(.checkLogin(parameter))
        }.store(in: &cancellables)
        
        reviewListCollectionView.imageTapPublisher.sink { [weak self] image in
            guard let image = image else { return }
            let imageWidth: CGFloat = UIScreen.main.bounds.width - 48
            let smallProportion: CGFloat = image.size.width / imageWidth
            let imageHeight: CGFloat = image.size.height / smallProportion
            let zoomedImageViewController = ZoomedImageViewController(imageWidth: imageWidth, imageHeight: imageHeight.isNaN ? 100 : imageHeight)
            zoomedImageViewController.setImage(image)
            self?.present(zoomedImageViewController, animated: true, completion: nil)
        }.store(in: &cancellables)
    }
    
}

extension ReviewListViewController {
    
    @objc private func writeReviewButtonTapped() {
        inputSubject.send(.checkLogin(nil))
    }
    
    private func navigateToReportReview(parameter: (Int, Int)) {
        let shopReviewReportViewController = ShopReviewReportViewController(viewModel: ShopReviewReportViewModel(reportReviewReviewUseCase: DefaultReportReviewUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), reviewId: parameter.0, shopId: parameter.1, shopName: viewModel.shopName))
        self.shopReviewReportViewController = shopReviewReportViewController
            navigationController?.pushViewController(shopReviewReportViewController, animated: true)
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
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        
        let shopReviewViewController = ShopReviewViewController(viewModel: ShopReviewViewModel(postReviewUseCase: postReviewUseCase, modifyReviewUseCase: modifyReviewUseCase, fetchShopReviewUseCase: fetchShopReviewUseCase, uploadFileUseCase: uploadFileUseCase, fetchShopDataUseCase: fetchShopDataUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase, shopId: viewModel.shopId, shopName: viewModel.shopName))
        shopReviewViewController.title = "리뷰 작성하기"
        self.shopReviewViewController = shopReviewViewController
        if let viewController = self.shopReviewViewController {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewWrite, .click, viewModel.shopName))
            navigationController?.pushViewController(viewController, animated: true)
        }
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

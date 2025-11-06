//
//  ReviewListViewController.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Combine
import UIKit
import SnapKit

final class ReviewListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ReviewListViewModel
    private let inputSubject: PassthroughSubject<ReviewListViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let writeReviewButton = UIButton().then {
        $0.setTitleColor(UIColor.appColor(.new500), for: .normal)
        $0.layer.borderColor = UIColor.appColor(.new500).cgColor
        $0.layer.cornerRadius = 8
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
        return ScoreChartCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    private let reviewListCollectionView: ReviewListCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return ReviewListCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    private let nonReviewListView = NonReviewListView().then {
        $0.isHidden = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }
    
    // MARK: - Modal ViewControllers
    
    private lazy var reviewWriteLoginModalViewController = ReviewLoginModalViewController(message: "작성").then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private lazy var reviewReportLoginModalViewController = ReviewLoginModalViewController(message: "신고").then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private lazy var deleteReviewModalViewController = DeleteReviewModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    // MARK: - Initialize
    
    init(viewModel: ReviewListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(shopId: Int, shopName: String) {
        let viewModel = ReviewListViewModel(shopId: shopId, shopName: shopName)
        self.init(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
        setDelegate()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .white)
    }
        
    private func bind() {
        bindViewModel()
        bindCollectionView()
        bindModalViewControllers()
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case let .updateLoginStatus(isLogined, parameter):
                    self.handleLoginStatus(isLogined: isLogined, parameter: parameter)
                    
                case let .setReviewList(reviews, sortType, isMineOnly, _, _, shouldReset):
                    self.updateReviewList(
                        reviews: reviews,
                        sortType: sortType,
                        isMineOnly: isMineOnly,
                        shouldReset: shouldReset
                    )
                    
                case let .setStatistics(statistics):
                    self.updateStatistics(statistics)
                    
                case let .updateLoadingState(isLoading):
                    if isLoading {
                        self.loadingIndicator.startAnimating()
                    } else {
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindCollectionView() {
        reviewListCollectionView.myReviewButtonPublisher
            .sink { [weak self] isMine in
                self?.inputSubject.send(.changeFilter(sorter: nil, isMine: isMine))
            }
            .store(in: &cancellables)
        
        reviewListCollectionView.sortTypeButtonPublisher
            .sink { [weak self] _ in
                self?.showSortBottomSheet()
            }
            .store(in: &cancellables)
        
        reviewListCollectionView.deleteButtonPublisher
            .sink { [weak self] parameter in
                self?.handleDeleteReview(parameter)
            }
            .store(in: &cancellables)
        
        reviewListCollectionView.modifyButtonPublisher
            .sink { [weak self] parameter in
                self?.navigateToModifyReview(reviewId: parameter.0, shopId: parameter.1)
            }
            .store(in: &cancellables)
        
        reviewListCollectionView.reportButtonPublisher
            .sink { [weak self] parameter in
                self?.inputSubject.send(.checkLogin(parameter))
            }
            .store(in: &cancellables)
        
        reviewListCollectionView.heightChangePublisher
            .sink { [weak self] count in
                self?.updateCollectionViewHeight(reviewCount: count)
            }
            .store(in: &cancellables)
        
        reviewListCollectionView.imageTapPublisher
            .sink { [weak self] image in
                self?.showZoomedImage(image)
            }
            .store(in: &cancellables)
    }
    
    private func bindModalViewControllers() {
        reviewWriteLoginModalViewController.loginButtonPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.inputSubject.send(.logEvent(
                    EventParameter.EventLabel.Business.loginPrompt,
                    .click,
                    "리뷰 작성 팝업"
                ))
                self.showLoginScreen()
            }
            .store(in: &cancellables)
        
        reviewWriteLoginModalViewController.cancelButtonPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.inputSubject.send(.logEvent(
                    EventParameter.EventLabel.Business.shopDetailViewReviewWriteCancel,
                    .click,
                    self.viewModel.getShopName()
                ))
            }
            .store(in: &cancellables)
        
        deleteReviewModalViewController.deleteButtonPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.inputSubject.send(.logEvent(
                    EventParameter.EventLabel.Business.shopDetailViewReviewDeleteDone,
                    .click,
                    self.viewModel.getShopName()
                ))
                self.deleteReview()
            }
            .store(in: &cancellables)
        
        reviewReportLoginModalViewController.loginButtonPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.inputSubject.send(.logEvent(
                    EventParameter.EventLabel.Business.loginPrompt,
                    .click,
                    "리뷰 신고 팝업"
                ))
                self.showLoginScreen()
            }
            .store(in: &cancellables)
    }
        
    private func setAddTarget() {
        writeReviewButton.addTarget(self, action: #selector(writeReviewButtonTapped), for: .touchUpInside)
    }
    
    private func setDelegate() {
        scrollView.delegate = self
    }
}

extension ReviewListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        let threshold: CGFloat = 100
        
        if offsetY > contentHeight - frameHeight - threshold {
            if viewModel.canFetchMore {
                inputSubject.send(.fetchNextPage)
            }
        }
    }
}

extension ReviewListViewController {
    
    private func updateReviewList(reviews: [Review], sortType: ReviewSortType, isMineOnly: Bool, shouldReset: Bool
    ) {
        if shouldReset {
            reviewListCollectionView.resetReviewList()
        }
        reviewListCollectionView.addReviewList(reviews)
        reviewListCollectionView.setHeader(sortType, isMineOnly)
        updateCollectionViewHeight(reviewCount: reviews.count)
    }
    
    private func updateStatistics(_ statistics: StatisticsDto) {
        totalScoreLabel.text = "\(statistics.averageRating)"
        totalScoreView.rating = statistics.averageRating
        scoreChartCollectionView.setStatistics(statistics)
    }
    
    private func updateCollectionViewHeight(reviewCount: Int) {
        let height = reviewListCollectionView.calculateDynamicHeight()
        
        reviewListCollectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        nonReviewListView.isHidden = reviewCount != 0
    }
    
    private func showSortBottomSheet() {
        let options = ReviewSortType.allCases.map { $0.koreanDescription }
        
        let currentSortType = viewModel.getCurrentSortType()
        let selectedIndex = ReviewSortType.allCases.firstIndex(of: currentSortType) ?? 0
        
        let bottomSheet = SortTypeBottomSheetViewController(
            options: options,
            selectedIndex: selectedIndex
        )
        
        bottomSheet.selectionPublisher
            .sink { [weak self] index in
                let selectedSortType = ReviewSortType.allCases[index]
                self?.inputSubject.send(.changeFilter(sorter: selectedSortType, isMine: nil))
            }
            .store(in: &cancellables)
        
        present(bottomSheet, animated: false)
    }
    
    private func handleLoginStatus(isLogined: Bool, parameter: (Int, Int)?) {
        if !isLogined {
            let modal = parameter != nil
                ? reviewReportLoginModalViewController
                : reviewWriteLoginModalViewController
            present(modal, animated: true)
        } else {
            if let parameter {
                navigateToReportReview(reviewId: parameter.0, shopId: parameter.1)
            } else {
                navigateToWriteReview()
            }
        }
    }
    
    private func handleDeleteReview(_ parameter: (Int, Int)) {
        viewModel.deleteParameter = parameter
        inputSubject.send(.logEvent(
            EventParameter.EventLabel.Business.shopDetailViewReviewDelete,
            .click,
            viewModel.getShopName()
        ))
        present(deleteReviewModalViewController, animated: true)
    }
    
    private func deleteReview() {
        let (reviewId, shopId) = viewModel.deleteParameter
        reviewListCollectionView.disappearReview(reviewId, shopId: shopId)
        showToastMessage(message: "리뷰가 삭제되었어요")
    }
    
    private func showZoomedImage(_ image: UIImage?) {
        guard let image else { return }
        
        let imageWidth = UIScreen.main.bounds.width
        let proportion = image.size.width / imageWidth
        let imageHeight = image.size.height / proportion
        
        let zoomedImageViewController = ZoomedImageViewController(
            imageWidth: imageWidth,
            imageHeight: imageHeight.isNaN ? 100 : imageHeight
        )
        zoomedImageViewController.setImage(image)
        present(zoomedImageViewController, animated: true)
    }
}

// MARK: - Navigation

extension ReviewListViewController {
    
    @objc private func writeReviewButtonTapped() {
        inputSubject.send(.checkLogin(nil))
    }
    
    private func navigateToWriteReview() {
        let viewController = makeShopReviewViewController(
            reviewId: nil,
            shopId: viewModel.getShopId(),
            shopName: viewModel.getShopName()
        )
        viewController.title = "리뷰 작성하기"
        
        bindShopReviewViewController(viewController)
        
        inputSubject.send(.logEvent(
            EventParameter.EventLabel.Business.shopDetailViewReviewWrite,
            .click,
            viewModel.getShopName()
        ))
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToModifyReview(reviewId: Int, shopId: Int) {
        let viewController = makeShopReviewViewController(reviewId: reviewId, shopId: shopId, shopName: viewModel.getShopName())
        viewController.title = "리뷰 수정하기"
        
        bindShopReviewViewController(viewController)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToReportReview(reviewId: Int, shopId: Int) {
        let viewController = makeShopReviewReportViewController(reviewId: reviewId, shopId: shopId, shopName: viewModel.getShopName())
        
        bindShopReviewReportViewController(viewController)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLoginScreen() {
        navigateToLogin()
    }
}

extension ReviewListViewController {
    
    private func makeShopReviewViewController(reviewId: Int?, shopId: Int, shopName: String) -> ShopReviewViewController {
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        
        let viewModel = ShopReviewViewModel(
            postReviewUseCase: DefaultPostReviewUseCase(shopRepository: shopRepository),
            modifyReviewUseCase: DefaultModifyReviewUseCase(shopRepository: shopRepository),
            fetchShopReviewUseCase: DefaultFetchShopReviewUseCase(shopRepository: shopRepository),
            uploadFileUseCase: DefaultUploadFileUseCase(shopRepository: shopRepository),
            fetchShopDataUseCase: DefaultFetchShopDataUseCase(shopRepository: shopRepository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            getUserScreenTimeUseCase: DefaultGetUserScreenTimeUseCase(),
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName
        )
        
        return ShopReviewViewController(viewModel: viewModel)
    }
    
    private func makeShopReviewReportViewController(reviewId: Int, shopId: Int, shopName: String) -> ShopReviewReportViewController {
        let viewModel = ShopReviewReportViewModel(
            reportReviewReviewUseCase: DefaultReportReviewUseCase(
                shopRepository: DefaultShopRepository(service: DefaultShopService())
            ),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName
        )
        
        return ShopReviewReportViewController(viewModel: viewModel)
    }
    
    private func bindShopReviewViewController(_ viewController: ShopReviewViewController) {
        viewController.writeCompletePublisher
            .sink { [weak self] result in
                let isPost = result.0
                if isPost {
                    self?.inputSubject.send(.changeFilter(sorter: .latest, isMine: nil))
                } else if let reviewId = result.1 {
                    self?.reviewListCollectionView.modifySuccess(reviewId, result.2)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindShopReviewReportViewController(_ viewController: ShopReviewReportViewController) {
        viewController.reviewInfoPublisher
            .sink { [weak self] tuple in
                self?.showToastMessage(message: "리뷰가 신고되었어요.", intent: .neutral)
                self?.reviewListCollectionView.reportReview(tuple.0, shopId: tuple.1)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UI Function

extension ReviewListViewController {
    
    private func setUpLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [writeReviewButton, totalScoreLabel, totalScoreView, scoreChartCollectionView, reviewListCollectionView, nonReviewListView, loadingIndicator
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        writeReviewButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
        
        totalScoreLabel.snp.makeConstraints {
            $0.top.equalTo(writeReviewButton.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(45)
        }
        
        totalScoreView.snp.makeConstraints {
            $0.top.equalTo(totalScoreLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(88)
            $0.height.equalTo(16)
        }
        
        scoreChartCollectionView.snp.makeConstraints {
            $0.top.equalTo(writeReviewButton.snp.bottom).offset(14)
            $0.leading.equalTo(totalScoreView.snp.trailing).offset(14)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(95)
        }
        
        reviewListCollectionView.snp.makeConstraints {
            $0.top.equalTo(scoreChartCollectionView.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        nonReviewListView.snp.makeConstraints {
            $0.top.equalTo(reviewListCollectionView.snp.bottom).offset(95)
            $0.centerX.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setupConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}
